class AuthController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :login, :verify_token, :logout, :refresh_token ]

  SECRET_KEY = Rails.application.secret_key_base

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      token = generate_token(user_id: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def verify_token
    token = request.headers["Authorization"]&.split(" ")&.last
    decoded_token = decode_token(token)

    if decoded_token
      render json: { valid: true, user_id: decoded_token[:user_id], expires_at: Time.at(decoded_token[:exp]) }, status: :ok
    else
      render json: { valid: false, error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  def logout
    token = request.headers["Authorization"]&.split(" ")&.last
    if token
      decoded_token = decode_token(token)
      if decoded_token
        # Save both the received token and the decoded jti for logging and security purposes
        BlacklistedToken.create!(jti: decoded_token[:jti], received_token: token)
        render json: { message: "Logged out successfully" }, status: :ok
      else
        render json: { error: "Invalid token" }, status: :unauthorized
      end
    else
      render json: { error: "No token provided" }, status: :unauthorized
    end
  end

  def refresh_token
    refresh_token = params[:refresh_token]
    decoded_token = decode_token(refresh_token)

    if decoded_token
      new_token = generate_token(user_id: decoded_token[:user_id])
      render json: { token: new_token }, status: :ok
    else
      render json: { error: "Invalid or expired refresh token" }, status: :unauthorized
    end
  end

  private

  def generate_token(payload)
    payload[:jti] = SecureRandom.uuid # Set a unique identifier for the token
    payload[:exp] = 24.hours.from_now.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def decode_token(token)
    return nil unless token

    begin
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: "HS256" }).first.symbolize_keys
      jti = decoded[:jti]

      # Check if the token's JTI is blacklisted
      return nil if BlacklistedToken.exists?(jti: jti)

      decoded
    rescue JWT::DecodeError, JWT::ExpiredSignature
      nil
    end
  end
end
