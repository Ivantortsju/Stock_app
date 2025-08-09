class AddFundsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :funds, :decimal, precision: 15, scale: 2, default: 0.0
  end
end
