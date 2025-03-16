class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :jwt_authenticatable,
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  has_many :api_keys

  def jwt_token
    Warden::JWTAuth::UserEncoder.new.call(self, :user, nil).first
  end
end