class ApiKeySerializer
  include JSONAPI::Serializer

  attributes :id, :key, :status, :created_at, :usage_count, :last_used_at
  belongs_to :user, serializer: UserSerializer
end