ActiveAdmin.register Order do
  # Only permit the actual columns in the orders table
  permit_params :customer_id, :status, :subtotal, :gst_amount, :pst_amount, :hst_amount, :total_amount

  # Filters for admin
  filter :customer
  filter :status
  filter :created_at

  # Index page
  index do
    selectable_column
    id_column
    column :customer
    column :status
    column("Items") { |order| order.order_items.count }
    column("Subtotal") { |order| number_to_currency(order.subtotal) }
    column("GST") { |order| number_to_currency(order.gst_amount) }
    column("PST") { |order| number_to_currency(order.pst_amount) }
    column("HST") { |order| number_to_currency(order.hst_amount) }
    column("Total") { |order| number_to_currency(order.total_amount) }
    column :created_at
    actions
  end

  # Show page
  show do
    attributes_table do
      row :id
      row :customer
      row :status
      row("Subtotal") { |order| number_to_currency(order.subtotal) }
      row("GST") { |order| number_to_currency(order.gst_amount) }
      row("PST") { |order| number_to_currency(order.pst_amount) }
      row("HST") { |order| number_to_currency(order.hst_amount) }
      row("Total") { |order| number_to_currency(order.total_amount) }
      row :created_at
      row :updated_at
    end

    panel "Order Items" do
      table_for order.order_items do
        column :product
        column :quantity
        column("Price") { |item| number_to_currency(item.price) }
      end
    end
  end

  # Form for new/edit
  form do |f|
    f.semantic_errors

    f.inputs "Order Details" do
      f.input :customer, as: :select, collection: Customer.all.map { |c| [ c.email, c.id ] }
      f.input :status
      f.input :subtotal
      f.input :gst_amount, label: "GST"
      f.input :pst_amount, label: "PST"
      f.input :hst_amount, label: "HST"
      f.input :total_amount, label: "Total"
    end

    f.actions
  end
end
