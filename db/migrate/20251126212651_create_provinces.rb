class CreateProvinces < ActiveRecord::Migration[8.1]
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :abbreviation
      t.decimal :gst_rate
      t.decimal :pst_rate

      t.timestamps
    end
    add_index :provinces, :name, unique: true
    add_index :provinces, :abbreviation, unique: true
  end
end
