class ApiKeySerializer
  include JSONAPI::Serializer

  attributes :id, :key, :status, :usage_count, :last_used_at, :created_at, :expires_at, :iso8601
  belongs_to :user, serializer: UserSerializer
end