class CheckoutsController < ApplicationController
  before_action :initialize_cart
  before_action :ensure_cart_not_empty, only: [ :new, :confirm ]

  # Show checkout form with invoice
  def new
    # Use current customer or create a new one with their info pre-filled
    @customer = current_customer || Customer.new

    # Get products from cart
    @products = Product.where(id: @cart.keys)

    # Calculate subtotal
    @subtotal = calculate_subtotal(@products)

    # Calculate taxes based on customer's province or default to first province
    calculate_taxes(@customer, @subtotal)

    # Calculate total
    @total = @subtotal + @gst + @pst + @hst
  end

# Process checkout and create order
def confirm
  # Build or update customer
  if current_customer
    @customer = current_customer
    @customer.assign_attributes(customer_params)
  else
    # For guest checkout, create customer with proper email
    @customer = Customer.new(customer_params.merge(
      email: "guest_#{SecureRandom.hex(8)}@moncella.com", # Generate unique guest email
      password: SecureRandom.hex(10)
    ))
  end

  # Validate and save customer
  unless @customer.save
    prepare_checkout_view
    flash.now[:alert] = "Please correct the errors below: #{@customer.errors.full_messages.join(', ')}"
    render :new, status: :unprocessable_entity
    return
  end

  # Get products and validate cart
  @products = Product.where(id: @cart.keys)
  if @products.empty?
    redirect_to cart_path, alert: "Your cart is empty."
    return
  end

  # Calculate order totals
  @subtotal = calculate_subtotal(@products)

  # Get province tax - use customer's province
  province_tax = ProvinceTax.find_by(id: @customer.province_id)
  unless province_tax
    prepare_checkout_view
    flash.now[:alert] = "Invalid province selected."
    render :new, status: :unprocessable_entity
    return
  end

  # Calculate taxes
  @gst = @subtotal * (province_tax.gst / 100.0)
  @pst = @subtotal * (province_tax.pst / 100.0)
  @hst = @subtotal * (province_tax.hst / 100.0)
  @total = @subtotal + @gst + @pst + @hst

  # Create Stripe PaymentIntent
  begin
    payment_intent = Stripe::PaymentIntent.create({
      amount: (@total * 100).to_i, # Stripe uses cents
      currency: "cad",
      automatic_payment_methods: { enabled: true },
      metadata: {
        customer_email: @customer.email,
        customer_username: @customer.username
      }
    })
  rescue Stripe::StripeError => e
    prepare_checkout_view
    flash.now[:alert] = "Payment processing error: #{e.message}"
    render :new, status: :unprocessable_entity
    return
  end

  # Create order - use the SAME province_id as customer
  order = @customer.orders.build(
    province_id: @customer.province_id, # Use customer's province_id directly
    status: "pending",
    order_date: Time.current,
    subtotal: @subtotal,
    gst_amount: @gst,
    pst_amount: @pst,
    hst_amount: @hst,
    total_amount: @total,
    payment_intent_id: payment_intent.id
  )

  # Use transaction to ensure all or nothing
  ActiveRecord::Base.transaction do
    unless order.save
      prepare_checkout_view
      flash.now[:alert] = "Could not create order: #{order.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
      raise ActiveRecord::Rollback
    end

    # Create order items from cart
    @cart.each do |product_id, quantity|
      product = @products.find { |p| p.id.to_s == product_id }
      next unless product

      # Check item stock availability
      if product.stock_quantity < quantity
        flash.now[:alert] = "Insufficient stock for #{product.name}. Only #{product.stock_quantity} available."
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # Create order item
      order_item = order.order_items.build(
        product: product,
        quantity: quantity,
        price: product.price
      )

      unless order_item.save
        flash.now[:alert] = "Could not add #{product.name} to order: #{order_item.errors.full_messages.join(', ')}"
        render :new, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end

      # Reduce stock quantity
      product.update!(stock_quantity: product.stock_quantity - quantity)
    end

    # Store order ID and payment intent client secret in session for payment page
    session[:pending_order_id] = order.id
    session[:payment_client_secret] = payment_intent.client_secret

    # Redirect to payment page
    redirect_to payment_path
  end
end

  private

  def initialize_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def ensure_cart_not_empty
    if @cart.empty?
      redirect_to cart_path, alert: "Your cart is empty. Add some products before checking out."
    end
  end

  def customer_params
    params.require(:customer).permit(:username, :street, :city, :postal_code, :province_id)
  end

  def calculate_subtotal(products)
    products.sum { |p| p.price * @cart[p.id.to_s].to_i }
  end

  def calculate_taxes(customer, subtotal)
    province_tax = if customer.province_id.present?
                    ProvinceTax.find_by(id: customer.province_id)
    else
                    ProvinceTax.first
    end

    province_tax ||= OpenStruct.new(gst: 0, pst: 0, hst: 0)

    @gst = subtotal * (province_tax.gst.to_f / 100.0)
    @pst = subtotal * (province_tax.pst.to_f / 100.0)
    @hst = subtotal * (province_tax.hst.to_f / 100.0)
  end

  def prepare_checkout_view
    @products ||= Product.where(id: @cart.keys)
    @subtotal ||= calculate_subtotal(@products)
    calculate_taxes(@customer, @subtotal)
    @total = @subtotal + @gst + @pst + @hst
  end

  def number_with_precision(number, options = {})
    ActionController::Base.helpers.number_with_precision(number, options)
  end
end
