ActiveAdmin.register Page do
  permit_params :name, :content

  form do |f|
    f.inputs do
      f.input :name, as: :select, collection: [ "about", "contact" ], include_blank: false
      f.input :content, as: :text # changed from :quill_editor to :text
    end
    f.actions
  end
end
