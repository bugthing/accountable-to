class GoalMessage < ApplicationRecord
  acts_as_message chat_class: Goal, tool_call_class: ToolCall

  belongs_to :goal
  has_many_attached :attachments

  validates :role, presence: true, inclusion: {in: %w[user assistant system tool]}
  # validates :content, presence: true

  scope :chronological, -> { order(:created_at) }
  scope :by_role, ->(role) { where(role: role) }
end
