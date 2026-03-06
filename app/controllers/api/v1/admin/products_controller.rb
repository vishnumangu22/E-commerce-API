class Api::V1::Admin::ProductsController < ApplicationController
  before_action :require_admin
  before_action :set_product, only: [ :show, :update, :destroy ]

  def index
    render json: Product.all
  end

  def show
    render json: @product
  end

  def create
    description = params[:description]

    if description.blank?
      description = GroqService.generate_description(params[:name])
    end

    product = Product.new(
      name: params[:name],
      category: params[:category],
      price: params[:price],
      stock: params[:stock],
      description: description
    )

    if product.save
      render json: product, status: :created
    else
      render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: @product
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    render json: { message: "Product deleted successfully" }
  end



  private

  def set_product
    @product = Product.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Product not found" }, status: :not_found
  end

  def product_params
    params.permit(:name, :category, :description, :price, :stock)
  end
end
