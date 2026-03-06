class Api::V1::UsersController < ApplicationController
  def index
    render json: User.all
  end

  def show
    render json: User.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    render json: { message: "User deleted" }
  end
end
