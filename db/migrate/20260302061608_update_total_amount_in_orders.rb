class UpdateTotalAmountInOrders < ActiveRecord::Migration[8.1]
  def change
    change_column :orders, :total_amount, :decimal, precision: 10, scale: 2, default: 0
  end
end
