class CartItem < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Validations
  validates :user_id, presence: true
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Prevent duplicate cart items for same user/product
  validates :product_id, uniqueness: { scope: :user_id, message: "already in cart" }
end
