class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :province_tax, class_name: "ProvinceTax", foreign_key: "province_id"
  has_many :order_items, dependent: :destroy

  validates :status, presence: true
  validates :subtotal, :gst_amount, :pst_amount, :hst_amount, :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validates :province_id, presence: true

  before_validation :set_default_status, on: :create

  # Allow associations for ransack
  def self.ransackable_associations(auth_object = nil)
    %w[customer order_items province_tax]
  end

  # Allow attributes for ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id customer_id status subtotal gst_amount pst_amount hst_amount total_amount province_id payment_intent_id created_at updated_at]
  end

  # Mark order as paid
  def mark_as_paid!(payment_intent_id)
    update!(
      status: "paid",
      payment_intent_id: payment_intent_id
    )
  end

  private

  def set_default_status
    self.status ||= "pending"
  end
end
