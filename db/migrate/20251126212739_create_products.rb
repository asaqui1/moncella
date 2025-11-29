class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :name
      t.text :description
      t.decimal :price
      t.boolean :on_sale
      t.integer :stock_quantity
      t.string :sku

      t.timestamps
    end
  end
end
