class ToolCall < ApplicationRecord
  acts_as_tool_call message_class: GoalMessage
end
