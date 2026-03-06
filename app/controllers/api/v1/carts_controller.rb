class Api::V1::CartsController < ApplicationController
  def show
    cart = @current_user.cart
    return render json: [] unless cart

    render json: cart.cart_items.includes(:product)
  end


  def add_item
    cart = @current_user.cart || @current_user.create_cart

    product = Product.find_by(id: params[:product_id])
    return render json: { error: "Product not found" }, status: :not_found unless product

    quantity = params[:quantity].to_i
    return render json: { error: "Quantity must be greater than 0" }, status: :unprocessable_entity if quantity <= 0

    cart_item = cart.cart_items.find_or_initialize_by(product_id: product.id)
    cart_item.quantity = quantity
    cart_item.save!

    render json: {
      message: "Cart updated successfully",
      cart_items: cart.cart_items.includes(:product)
    }
  end

  def remove_item
    cart = @current_user.cart
    return render json: { error: "Cart not found" }, status: :not_found unless cart

    cart_item = cart.cart_items.find_by(product_id: params[:product_id])
    return render json: { error: "Item not found" }, status: :not_found unless cart_item

    remove_qty = params[:quantity].to_i

    if remove_qty <= 0 || remove_qty >= cart_item.quantity
      cart_item.destroy
    else
      cart_item.update(quantity: cart_item.quantity - remove_qty)
    end

    render json: {
      message: "Cart updated successfully",
      cart_items: cart.cart_items.includes(:product)
    }
  end
end
