class AddUniqueIndexToWishlists < ActiveRecord::Migration[8.1]
  def change
    remove_index :wishlists, :user_id
    add_index :wishlists, :user_id, unique: true
  end
end
