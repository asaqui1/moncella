class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Allow associations for Ransack
  def self.ransackable_associations(auth_object = nil)
    %w[order product]
  end

  # Allow attributes for Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id order_id product_id quantity price created_at updated_at]
  end
end
