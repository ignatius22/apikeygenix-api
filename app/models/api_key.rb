class ApiKey < ApplicationRecord
  belongs_to :user
  validates :key, presence: true, uniqueness: true
  before_validation :generate_key, on: :create
  before_create :set_default_expiration

  private

  def generate_key
    self.key ||= SecureRandom.hex(16)
    self.status ||= 'active'
    self.usage_count ||= 0
  end

  def set_default_expiration
    self.expires_at ||= 30.days.from_now
  end
end