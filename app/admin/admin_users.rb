ActiveAdmin.register AdminUser do
  permit_params :email, :password, :password_confirmation

  # Only show safe filters
  filter :email
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :email
    column :created_at
    column :updated_at
    actions
  end
end
