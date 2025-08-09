class CreateStockQuotes < ActiveRecord::Migration[7.0]
  def change
    create_table :stock_quotes do |t|
      t.string :ticker, null: false
      t.decimal :last_price, precision: 15, scale: 2, null: false
      t.string :name
      t.datetime :fetched_at, null: false
      t.timestamps
    end
    add_index :stock_quotes, :ticker
  end
end
