class Category < ApplicationRecord
  has_many :products

  # Validations
  validates :name, presence: true, uniqueness: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }

  # Only allow these attributes for search
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "description", "created_at", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
