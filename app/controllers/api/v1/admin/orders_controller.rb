class Api::V1::Admin::OrdersController < ApplicationController
  before_action :require_admin
  before_action :set_order, only: [ :show, :update ]

  def index
    render json: Order.includes(:order_items)
  end

  def show
    render json: @order, include: :order_items
  end


  def update
    @order.transition_to!(params[:status], actor: :admin)

    if @order.cancelled?
      ActiveRecord::Base.transaction do
        @order.order_items.each do |item|
          product = Product.lock.find(item.product_id)
          product.update!(stock: product.stock + item.quantity)
        end
      end
    end

    render json: @order

  rescue Order::InvalidTransitionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def set_order
    @order = Order.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end
end
