module Api
    module V1
      class WeatherController < ApplicationController
        before_action :authenticate_with_api_key
  
        def show
          render json: { city: params[:city], temp: '15°C', condition: 'Cloudy' }, status: :ok
        end
  
        private
  
        def authenticate_with_api_key
          token = request.headers['Authorization']&.split('Bearer ')&.last
          @api_key = ApiKey.find_by(key: token, status: 'active')&.where('expires_at > ?', Time.current)
          render json: { error: 'Invalid or revoked API key' }, status: :unauthorized unless @api_key
        end
      end
    end
end