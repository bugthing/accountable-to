class User < ApplicationRecord
  MAX_GOALS = 2

  has_many :goals, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :goals, length: {maximum: MAX_GOALS, message: "You can have a maximum of %maximum goals"}

  before_create :generate_confirmation_token

  def confirmed? = confirmed_at.present?

  def confirmation_expired?
    confirmation_token_generated_at < 1.hour.ago if confirmation_token_generated_at
  end

  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  def generate_magic_link!
    update!(
      magic_link_token: SecureRandom.urlsafe_base64(32),
      magic_link_token_generated_at: Time.current
    )
  end

  def magic_link_expired?
    magic_link_token_generated_at < 1.hour.ago if magic_link_token_generated_at
  end

  def clear_magic_link!
    update!(magic_link_token: nil, magic_link_token_generated_at: nil)
  end

  def at_goal_limit?
    goals.count >= MAX_GOALS
  end

  private

  def generate_confirmation_token
    self.confirmation_token = SecureRandom.urlsafe_base64(32)
    self.confirmation_token_generated_at = Time.current
  end
end
