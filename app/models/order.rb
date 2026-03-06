class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  class InvalidTransitionError < StandardError; end

  enum :status, {
    pending: 0,
    confirmed: 1,
    shipped: 2,
    delivered: 3,
    cancelled: 4
  }

  validates :status, presence: true


  ALLOWED_TRANSITIONS = {
    "pending"   => [ "confirmed", "cancelled" ],
    "confirmed" => [ "shipped", "cancelled" ],
    "shipped"   => [ "delivered" ],
    "delivered" => [],
    "cancelled" => []
  }.freeze

  TERMINAL_STATES = [ "delivered", "cancelled" ].freeze

  def transition_to!(new_status, actor:)
    new_status = new_status.to_s

    unless self.class.statuses.keys.include?(new_status)
      raise InvalidTransitionError, "Invalid status transition"
    end

    if TERMINAL_STATES.include?(status)
      raise InvalidTransitionError, "Invalid status transition"
    end

    if actor == :user && new_status != "cancelled"
      raise InvalidTransitionError, "Invalid status transition"
    end

    unless ALLOWED_TRANSITIONS[status].include?(new_status)
      raise InvalidTransitionError, "Invalid status transition"
    end

    update!(status: new_status)
  end
end
