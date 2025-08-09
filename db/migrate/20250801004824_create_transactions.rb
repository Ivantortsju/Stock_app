class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ticker
      t.integer :quantity
      t.decimal :price_per_share
      t.string :transaction_type

      t.timestamps
    end
  end
end
