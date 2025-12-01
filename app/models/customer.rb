class Customer < ApplicationRecord
  # Devise modules for authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Association with province_tax (using province_id foreign key)
  belongs_to :province_tax, foreign_key: "province_id", optional: true
  has_many :orders, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Address validations
  validates :street, length: { maximum: 255 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true
  validates :postal_code, format: { with: /\A[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d\z/, message: "must be valid Canadian postal code (e.g., A1A 1A1)" }, allow_blank: true
  validates :province_id, numericality: { only_integer: true }, allow_nil: true

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
end
