class Order < ApplicationRecord
  belongs_to :customer
  belongs_to :province_tax, class_name: "ProvinceTax", foreign_key: "province_id", optional: true
  has_many :order_items, dependent: :destroy

  validates :status, presence: true
  validates :subtotal, :gst_amount, :pst_amount, :hst_amount, :total_amount, numericality: { greater_than_or_equal_to: 0 }

  before_validation :set_default_status, on: :create
  before_validation :assign_province_tax, on: :create

  # Allow associations for ransack
  def self.ransackable_associations(auth_object = nil)
    %w[customer order_items province_tax]
  end

  # Allow attributes for ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[id customer_id status subtotal gst_amount pst_amount hst_amount total_amount province_id created_at updated_at]
  end

  private

  def set_default_status
    self.status ||= "new"
  end

  def assign_province_tax
    self.province_tax ||= customer.province_tax || ProvinceTax.first
  end
end
