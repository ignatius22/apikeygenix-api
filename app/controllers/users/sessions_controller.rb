class Users::SessionsController < ApplicationController
  respond_to :json
  before_action :authenticate_user!, only: [:me] # Protect /me with Devise JWT auth

  def create
    puts "Params: #{params.inspect}" # Keeping your debug style
    user = User.find_by(email: params[:user][:email]&.downcase)
    puts "User: #{user.inspect}"
    if user&.valid_password?(params[:user][:password])
      puts "Password valid, generating token..."
      token = user.jwt_token
      puts "Token: #{token.inspect}"
      render json: { 
        token: token, 
        email: user.email,
        username: user.email.split('@')[0] # Added for frontend
      }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def me
    Rails.logger.debug "Fetching current user: #{current_user.inspect}"
    render json: { email: current_user.email, username: current_user.email.split('@')[0] }, status: :ok
  end
end