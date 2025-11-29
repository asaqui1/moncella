class Customer < ApplicationRecord
  # Devise modules for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Association with province_tax (using province_id foreign key)
  belongs_to :province_tax, foreign_key: "province_id", optional: true
  has_many :orders, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  # Address validations - simplified (no format checking)
  validates :street, presence: true, if: :address_required?
  validates :city, presence: true, if: :address_required?
  validates :postal_code, presence: true, if: :address_required?
  validates :province_id, presence: true, if: :address_required?

  # Ransack's configuration
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "username", "email", "street", "city", "postal_code", "province_id", "created_at", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "province_tax", "orders" ]
  end

  # Helper method to get customer's full address
  def full_address
    return "Address not provided" unless street.present?
    [ street, city, province_tax&.name, postal_code ].compact.join(", ")
  end

  private

  def address_required?
    false # Set to true if you want to always require address
  end
end
