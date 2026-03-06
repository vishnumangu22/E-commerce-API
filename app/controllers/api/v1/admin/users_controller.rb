class Api::V1::Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [ :show, :destroy ]

  def index
    render json: User.all
  end

  def show
    render json: @user
  end

  def destroy
    @user.destroy
    render json: { message: "User deleted successfully" }
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end
end
