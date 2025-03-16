class ApiKeySerializer < ActiveModel::Serializer
  attributes :id, :key, :status, :created_at, :usage_count

end