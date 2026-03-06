class ApplicationController < ActionController::API
  before_action :authorize_request

  SECRET_KEY = Rails.application.secret_key_base

  private

  def encode_token(payload)
    JWT.encode(payload, SECRET_KEY)
  end

  def decode_token(token)
    JWT.decode(token, SECRET_KEY)[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end

  def authorize_request
    header = request.headers["Authorization"]

    return render json: { error: "Unauthorized" }, status: :unauthorized unless header.present?

    token = header.split(" ").last
    decoded = decode_token(token)

    return render json: { error: "Unauthorized" }, status: :unauthorized unless decoded

    @current_user = User.find_by(id: decoded["user_id"])

    render json: { error: "User not found" }, status: :unauthorized unless @current_user
  end


  def require_admin
    unless @current_user&.admin?
      render json: { error: "Forbidden - Admin access only" }, status: :forbidden
    end
  end
end
