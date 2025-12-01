class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :province_tax, class_name: "ProvinceTax", foreign_key: "province_id"
  has_many :order_items, dependent: :destroy

  # Validations
  validates :customer_id, presence: true
  validates :province_id, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending paid shipped delivered cancelled] }
  validates :subtotal, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :gst_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :pst_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :hst_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :order_date, presence: true
  validates :payment_intent_id, length: { maximum: 255 }, allow_blank: true

  before_validation :set_default_status, on: :create
  before_validation :set_order_date, on: :create

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

  def set_order_date
    self.order_date ||= Time.current
  end
end
