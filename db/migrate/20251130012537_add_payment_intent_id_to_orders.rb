class AddPaymentIntentIdToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_intent_id, :string
  end
end
