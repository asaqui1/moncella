class CreateProvinceTaxes < ActiveRecord::Migration[8.1]
  def change
    create_table :province_taxes do |t|
      t.string :name
      t.decimal :gst
      t.decimal :pst
      t.decimal :hst

      t.timestamps
    end
  end
end
