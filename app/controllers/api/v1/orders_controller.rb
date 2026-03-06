class Api::V1::OrdersController < ApplicationController
  def index
    render json: @current_user.orders.includes(:order_items)
  end

  def create
    cart = @current_user.cart

    if cart.blank? || cart.cart_items.empty?
      return render json: { error: "Cart is empty" }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      total = 0
      order = @current_user.orders.create!(status: :pending)

      cart.cart_items.each do |cart_item|
        product  = Product.lock.find(cart_item.product_id)
        quantity = cart_item.quantity

        if product.stock < quantity
          raise StandardError, "Insufficient stock for #{product.name}"
        end

        product.update!(stock: product.stock - quantity)

        subtotal = product.price * quantity
        total += subtotal

        order.order_items.create!(
          product: product,
          quantity: quantity,
          price: product.price
        )
      end

      order.update!(total_amount: total)
      cart.cart_items.destroy_all

      render json: { message: "Order placed successfully", order: order }, status: :created
    end

  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def update
    order = @current_user.orders.find(params[:id])


    order.transition_to!(params[:status], actor: :user)

    if order.cancelled?
      ActiveRecord::Base.transaction do
        order.order_items.each do |item|
          product = Product.lock.find(item.product_id)
          product.update!(stock: product.stock + item.quantity)
        end
      end
    end

    render json: order

  rescue Order::InvalidTransitionError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end
end
