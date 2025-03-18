module Api
  module V1
    class ApiKeysController < ApplicationController
      before_action :authenticate_with_jwt
      before_action :set_api_key, only: [:destroy, :use] # Add :use

      def index
        # render json: current_user.api_keys, each_serializer: ApiKeySerializer, status: :ok
        @api_key = ApiKey.all
        render json: ApiKeySerializer.new(@api_key).serializable_hash.to_json, status: :ok

      end

      def create
        api_key = current_user.api_keys.create(key: SecureRandom.hex(16), status: 'active')
        if api_key.persisted?
          render json: ApiKeySerializer.new(api_key).serializable_hash, status: :created
        else
          render json: { error: api_key.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      def destroy
        @api_key.update(status: 'revoked')
        render json: { message: 'API key revoked' }, status: :ok
      end

      def use
        if @api_key.status == 'revoked'
          render json: { error: 'API key is revoked' }, status: :forbidden
        else
          @api_key.increment!(:usage_count)
          @api_key.update(last_used_at: Time.current)
          render json: ApiKeySerializer.new(@api_key).serializable_hash, status: :ok
        end
      end

      private

      def set_api_key
        @api_key = current_user.api_keys.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'API key not found' }, status: :not_found
      end

      def authenticate_with_jwt
        token = request.headers['Authorization']&.split('Bearer ')&.last
        Rails.logger.info "Received Token: #{token}"
        unless token
          render json: { error: 'No token provided' }, status: :unauthorized and return
        end

        begin
          @current_user = Warden::JWTAuth::UserDecoder.new.call(token, :user, nil)
          Rails.logger.info "Authenticated User: #{@current_user.inspect}"
        rescue JWT::DecodeError => e
          Rails.logger.error "Decode Error: #{e.message}"
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
        rescue ActiveRecord::RecordNotFound => e
          Rails.logger.error "User Not Found: #{e.message}"
          render json: { error: 'Invalid or expired token' }, status: :unauthorized
        end
      end

      def current_user
        @current_user
      end
    end
  end
end