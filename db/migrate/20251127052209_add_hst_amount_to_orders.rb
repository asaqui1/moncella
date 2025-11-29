class AddHstAmountToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :hst_amount, :decimal
  end
end
