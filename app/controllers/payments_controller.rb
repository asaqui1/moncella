class PaymentsController < ApplicationController
  def show
    @order = Order.find_by(id: session[:pending_order_id])
    @client_secret = session[:payment_client_secret]

    unless @order && @client_secret
      redirect_to products_path, alert: "No pending payment found."
    end
  end

  def success
    order = Order.find_by(id: session[:pending_order_id])
    payment_intent_id = params[:payment_intent]

    if order && payment_intent_id
      # Verify payment with Stripe
      begin
        payment_intent = Stripe::PaymentIntent.retrieve(payment_intent_id)

        if payment_intent.status == "succeeded"
          order.mark_as_paid!(payment_intent_id)

          # Clear cart and session
          session[:cart] = {}
          session.delete(:pending_order_id)
          session.delete(:payment_client_secret)

          redirect_to order_path(order), notice: "Payment successful! Your order has been confirmed."
        else
          redirect_to payment_path, alert: "Payment was not successful. Please try again."
        end
      rescue Stripe::StripeError => e
        redirect_to payment_path, alert: "Error verifying payment: #{e.message}"
      end
    else
      redirect_to products_path, alert: "Invalid payment confirmation."
    end
  end

  def cancel
    session.delete(:pending_order_id)
    session.delete(:payment_client_secret)
    redirect_to cart_path, alert: "Payment cancelled."
  end
end
