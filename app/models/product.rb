class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 255 }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :sku, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :category_id, presence: true
  validates :on_sale, inclusion: { in: [ true, false ] }

  # Allowlist associations for search
  def self.ransackable_associations(auth_object = nil)
    [ "category", "image_attachment", "image_blob" ]
  end

  # Allowlist attributes for search
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "description", "price", "stock_quantity", "sku", "on_sale", "created_at", "updated_at" ]
  end
end
