ActiveAdmin.register Product do
  permit_params :name, :description, :price, :stock_quantity, :sku, :category_id, :on_sale, :image

  index do
    selectable_column
    id_column
    column :name
    column :category
    column :price
    column :on_sale
    column :stock_quantity
    column :image do |product|
      if product.image.attached?
        image_tag url_for(product.image), height: "50"
      end
    end
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :sku
      f.input :category
      f.input :on_sale
      f.input :image, as: :file
    end
    f.actions
  end
end
