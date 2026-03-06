class Api::V1::ProductsController < ApplicationController
  skip_before_action :authorize_request, only: [ :index, :show, :search, :recommendations ]

  def index
    products = Product.page(params[:page]).per(10)
    render json: products
  end

  def show
    product = Product.find(params[:id])
    render json: product
  end

  def create
    product = Product.create(product_params)
    render json: product
  end

  def update
    product = Product.find(params[:id])
    product.update(product_params)
    render json: product
  end

  def destroy
    Product.find(params[:id]).destroy
    render json: { message: "Deleted successfully" }
  end

  def search
    if params[:q].present?
      results = Product.search(params[:q])
      products = results.records
      render json: products
    else
      render json: { error: "Query parameter missing" }, status: :bad_request
    end
  end

  def recommendations
    product = Product.find(params[:id])

    candidates = Product
                  .where(category: product.category)
                  .where.not(id: product.id)
                  .limit(10)

    ai_names = RecommendationService.rank_products(product.name, candidates)

    recommended_products = candidates.select do |product|
      ai_names.any? do |ai_name|
        ai_name.downcase.include?(product.name.downcase)
      end
    end

    render json: {
      product: product.name,
      recommendations: recommended_products
    }
  end

  private

  def product_params
    params.permit(:name, :description, :price, :stock, :category)
  end
end
