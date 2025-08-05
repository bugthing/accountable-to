class Goal < ApplicationRecord
  acts_as_chat message_class: GoalMessage, tool_call_class: ToolCall

  belongs_to :user
  has_many :goal_messages, dependent: :destroy

  validates :description, presence: true, length: {minimum: 10, maximum: 1000}
  validates :frequency, presence: true, inclusion: {in: %w[daily weekly monthly]}
  validate :user_goal_limit

  after_create :generate_title_async,
    :generate_initial_message_async,
    :apply_defaults!

  scope :active, -> { where(removed_at: nil) }
  scope :due_for_checkin, -> { where(id: Goal.active.select { |goal| goal.due_for_checkin? }.map(&:id)) }

  def frequency_description
    case frequency
    when "daily"
      "Check in daily"
    when "weekly"
      "Check in weekly"
    when "monthly"
      "Check in monthly"
    end
  end

  def goal_messages_for_history
    goal_messages
      .where(role: [:user, :assistant])
      .chronological
  end

  def due_for_checkin?
    return true if last_message_at.nil?

    case frequency
    when "daily"
      last_message_at < 1.day.ago
    when "weekly"
      last_message_at < 1.week.ago
    when "monthly"
      last_message_at < 1.month.ago
    else
      false
    end
  end

  def last_message_at
    goal_messages.maximum(:created_at)
  end

  def reply_email_address(domain = Rails.configuration.action_mailer.default_url_options[:host])
    "goal-#{email_token}@#{domain}"
  end

  def broadcast_message_history_append
    message = goal_messages_for_history.last
    return unless message.present?

    broadcast_append_to(
      [self, :message_history],
      target: [self, :message_history_items],
      partial: "goals/message_history_item",
      locals: {message:}
    )
  end

  def most_recent_assistant_message
    goal_messages.by_role(:assistant).chronological.last
  end

  def removed? = removed_at.present?

  def remove! = update!(removed_at: Time.current)

  private

  def user_goal_limit
    return unless user

    if user.goals.where.not(id: id).count >= 2
      errors.add(:base, "You can only have a maximum of 2 goals")
    end
  end

  def generate_title_async
    GenerateGoalTitleJob.perform_later(id)
  end

  def generate_initial_message_async
    GenerateInitialMessageJob.perform_later(id)
  end

  def apply_defaults!
    self.telegram_token = SecureRandom.urlsafe_base64(32)
    self.email_token = SecureRandom.urlsafe_base64(4)
    save!
  end
end
