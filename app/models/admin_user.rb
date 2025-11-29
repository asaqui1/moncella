class AdminUser < ApplicationRecord
  # Devise modules
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  # Only allow safe attributes for search
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "email", "created_at", "updated_at" ]
  end

  # No associations needed for search
  def self.ransackable_associations(auth_object = nil)
    []
  end
end
