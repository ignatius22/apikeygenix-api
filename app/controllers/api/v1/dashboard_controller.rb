module Api
    module V1
      class DashboardController < ApplicationController
        before_action :authenticate_with_jwt
  
        def show
          render json: {
            data: {
              type: 'dashboard',
              attributes: {
                total_keys: current_user.api_keys.count,
                active_keys: current_user.api_keys.where(status: 'active').count,
                total_usage: current_user.api_keys.sum(:usage_count)
              }
            }
          }, status: :ok
        end
  
        private
  
        def authenticate_with_jwt
          token = request.headers['Authorization']&.split('Bearer ')&.last
          unless token
            render json: { error: 'No token provided' }, status: :unauthorized and return
          end
          begin
            @current_user = Warden::JWTAuth::UserDecoder.new.call(token, :user, nil)
          rescue JWT::DecodeError, ActiveRecord::RecordNotFound
            render json: { error: 'Invalid or expired token' }, status: :unauthorized
          end
        end
  
        def current_user
          @current_user
        end
      end
    end
  end