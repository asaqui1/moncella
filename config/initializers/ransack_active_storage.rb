Rails.application.config.to_prepare do
  # Allowlist ActiveStorage::Attachment attributes
  ActiveStorage::Attachment.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      [ "id", "name", "record_id", "record_type", "blob_id", "created_at" ]
    end

    def self.ransackable_associations(auth_object = nil)
      []
    end
  end

  # Allowlist ActiveStorage::Blob attributes
  ActiveStorage::Blob.class_eval do
    def self.ransackable_attributes(auth_object = nil)
      [ "id", "filename", "content_type", "byte_size", "checksum", "created_at" ]
    end

    def self.ransackable_associations(auth_object = nil)
      []
    end
  end
end
