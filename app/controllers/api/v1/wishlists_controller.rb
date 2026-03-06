module Api
  module V1
    class WishlistsController < ApplicationController
      # POST /api/v1/wishlist/add_item
      def add_item
        wishlist = find_or_create_wishlist

        product = Product.find_by(id: params[:product_id])
        return render json: { error: "Product not found" }, status: :not_found unless product

        if wishlist.products.exists?(id: product.id)
          return render json: { message: "Product already in wishlist" }, status: :ok
        end

        wishlist.wishlist_items.create!(product: product)

        render json: { message: "Product added to wishlist" }, status: :created
      end

      def show
        wishlist = @current_user.wishlist
        return render json: [] unless wishlist

        render json: wishlist.products, status: :ok
      end

      def remove_item
        wishlist = @current_user.wishlist
        return render json: { error: "Wishlist not found" }, status: :not_found unless wishlist

        item = wishlist.wishlist_items.find_by(product_id: params[:product_id])
        return render json: { error: "Item not found" }, status: :not_found unless item

        item.destroy

        render json: { message: "Product removed from wishlist" }, status: :ok
      end

      def move_to_cart
        wishlist = @current_user.wishlist
        return render json: { error: "Wishlist not found" }, status: :not_found unless wishlist

        item = wishlist.wishlist_items.find_by(product_id: params[:product_id])
        return render json: { error: "Item not found in wishlist" }, status: :not_found unless item

        cart = @current_user.cart || @current_user.create_cart

        cart_item = cart.cart_items.find_or_initialize_by(product_id: item.product_id)
        cart_item.quantity ||= 0
        cart_item.quantity += (params[:quantity] || 1).to_i
        cart_item.save!

        item.destroy

        render json: {
          message: "Product moved to cart successfully",
          cart_items: cart.cart_items.includes(:product)
        }
      end

      private

      def find_or_create_wishlist
        @current_user.wishlist || @current_user.create_wishlist
      end
    end
  end
end
