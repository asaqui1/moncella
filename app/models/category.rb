class Category < ApplicationRecord
  has_many :products

  # Only allow these attributes for search
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "description", "created_at", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
