class ProvinceTax < ApplicationRecord
  has_many :customers, foreign_key: "province_id"
  has_many :orders, foreign_key: "province_id"

  validates :name, presence: true, uniqueness: true
  validates :gst, :pst, :hst, numericality: { greater_than_or_equal_to: 0 }

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "gst", "pst", "hst", "created_at", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "customers", "orders" ]
  end

  # Calculate total tax rate
  def total_tax_rate
    gst + pst + hst
  end

  # Display name with tax info
  def name_with_taxes
    taxes = []
    taxes << "GST: #{gst}%" if gst > 0
    taxes << "PST: #{pst}%" if pst > 0
    taxes << "HST: #{hst}%" if hst > 0

    "#{name} (#{taxes.join(', ')})"
  end
end
