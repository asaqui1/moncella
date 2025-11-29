ActiveAdmin.register OrderItem do
  permit_params :order_id, :product_id, :quantity, :price

  # Filters
  filter :order
  filter :product

  index do
    selectable_column
    id_column
    column :order
    column :product
    column :quantity
    column("Price") { |item| number_to_currency(item.price) }
    actions
  end
end
