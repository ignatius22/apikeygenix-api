class UserSerializer
    include JSONAPI::Serializer
  
    attributes :id, :email
    has_many :api_key, serializer: ApiKeySerializer
end