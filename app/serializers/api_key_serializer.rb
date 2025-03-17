class ApiKeySerializer < ActiveModel::Serializer
  attributes :id, :key, :status, :created_at, :usage_count, :last_used_at
end