class ApplicationController < ActionController::API
  respond_to :json # Ensure JSON responses for API

  def root
    render json: { status: 'ok', message: 'ApiKeyGenix API is running', version: '1.0' }, status: :ok
  end
end
