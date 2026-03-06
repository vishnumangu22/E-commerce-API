class User < ApplicationRecord
  has_secure_password

  enum :role, { customer: 0, admin: 1 }

  has_many :orders, dependent: :destroy
  has_one  :cart, dependent: :destroy
  has_one  :wishlist, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
