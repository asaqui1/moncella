class Page < ApplicationRecord
  # Allow Ransack to search these attributes
  def self.ransackable_attributes(auth_object = nil)
    [ "id", "name", "content", "created_at", "updated_at" ]
  end
end
