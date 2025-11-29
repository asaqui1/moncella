class CartsController < ApplicationController
  before_action :initialize_cart
  before_action :authenticate_customer!, only: [ :checkout, :process_checkout ]

  # Show cart
  def show
    @cart_items = @cart.map do |product_id, quantity|
      product = Product.find_by(id: product_id)
      next unless product
      { product: product, quantity: quantity }
    end.compact
    @subtotal = @cart_items.sum { |item| item[:product].price * item[:quantity] }
  end

  # Add product to cart
  def add
    product_id = params[:product_id].to_s
    @cart[product_id] = (@cart[product_id] || 0) + 1
    save_cart
    redirect_back(fallback_location: products_path, notice: "Product added to cart!")
  end

  # Update product quantity
  def update
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i
    if quantity <= 0
      @cart.delete(product_id)
    else
      @cart[product_id] = quantity
    end
    save_cart
    redirect_to cart_path, notice: "Cart updated."
  end

  # Remove product from cart
  def remove
    product_id = params[:product_id].to_s
    @cart.delete(product_id)
    save_cart
    redirect_to cart_path, notice: "Item removed from cart."
  end

  # Checkout form
  def checkout
    @customer = current_customer
    @products = Product.where(id: @cart.keys)
  end

  # Process checkout
  def process_checkout
    @customer = current_customer
    @products = Product.where(id: @cart.keys)
    subtotal = @products.sum { |p| p.price * @cart[p.id.to_s] }

    # Province taxes
    province = ProvinceTax.find(params[:customer][:province_id])
    gst = subtotal * (province.gst / 100.0)
    pst = subtotal * (province.pst / 100.0)
    hst = subtotal * (province.hst / 100.0)
    total = subtotal + gst + pst + hst

    # Create order
    order = @customer.orders.create!(
      province_id: province.id,
      subtotal: subtotal,
      gst_amount: gst,
      pst_amount: pst,
      hst_amount: hst,
      total_amount: total,
      status: "new"
    )

    # Create order items
    @products.each do |product|
      order.order_items.create!(
        product: product,
        quantity: @cart[product.id.to_s],
        price: product.price
      )
    end

    # Clear cart
    session[:cart] = {}

    redirect_to products_path, notice: "Order placed successfully!"
  end

  private

  def initialize_cart
    session[:cart] ||= {}
    @cart = session[:cart]
  end

  def save_cart
    session[:cart] = @cart
  end
end
