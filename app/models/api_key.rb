class ApiKey < ApplicationRecord
  belongs_to :user
  validates :key, presence: true, uniqueness: true
  before_validation :generate_key, on: :create

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  private

  def generate_key
    self.key ||= SecureRandom.hex(16)
    self.status ||= 'active'
    self.usage_count ||= 0
    self.expires_at ||= 30.days.from_now # Moved expiration here
  end
end