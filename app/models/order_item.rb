class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Validations
  validates :order_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Prevent duplicate products in same order
  validates :product_id, uniqueness: { scope: :order_id, message: "already exists in this order" }

  # Allow associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[order product]
  end

  # Allow attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id order_id product_id quantity price created_at updated_at]
  end
end
