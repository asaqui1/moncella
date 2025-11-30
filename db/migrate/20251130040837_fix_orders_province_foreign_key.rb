class FixOrdersProvinceForeignKey < ActiveRecord::Migration[8.1]
  def change
    # Remove the old foreign key pointing to provinces
    remove_foreign_key :orders, :provinces

    # Add new foreign key pointing to province_taxes
    add_foreign_key :orders, :province_taxes, column: :province_id
  end
end
