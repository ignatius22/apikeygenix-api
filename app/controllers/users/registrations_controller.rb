class Users::RegistrationsController < Devise::RegistrationsController
    respond_to :json
  
    def create
      build_resource(sign_up_params)
      if resource.save
        render json: { 
          message: "User created successfully", 
          user: { email: resource.email }, 
          token: resource.jwt_token 
        }, status: :created
      else
        render json: { error: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def sign_up_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end