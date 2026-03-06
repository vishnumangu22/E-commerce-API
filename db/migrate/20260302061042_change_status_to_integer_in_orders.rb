class ChangeStatusToIntegerInOrders < ActiveRecord::Migration[8.1]
  def change
    remove_column :orders, :status
    add_column :orders, :status, :integer, default: 0, null: false
  end
end
