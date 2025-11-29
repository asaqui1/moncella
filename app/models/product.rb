class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image

  # Allowlist associations for search
  def self.ransackable_associations(auth_object = nil)
    [ "category", "image_attachment", "image_blob" ]
  end

  # Allowlist attributes for search
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "description", "price", "stock_quantity", "sku", "on_sale", "created_at", "updated_at" ]
  end
end
