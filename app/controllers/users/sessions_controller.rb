class Users::SessionsController < ApplicationController
    respond_to :json
  
    def create
      puts "Params: #{params.inspect}"
      user = User.find_by(email: params[:user][:email])
      puts "User: #{user.inspect}"
      if user&.valid_password?(params[:user][:password])
        puts "Password valid, generating token..."
        token = user.jwt_token
        puts "Token: #{token.inspect}"
        render json: { 
          token: token, 
          email: user.email 
        }, status: :ok
      else
        render json: { error: "Invalid email or password" }, status: :unauthorized
      end
    end
end