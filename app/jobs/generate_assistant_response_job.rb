class GenerateAssistantResponseJob < ApplicationJob
  queue_as :default

  def perform(goal_id, email_content)
    goal = Goal.find(goal_id)
    GoalMessageService.new(goal).generate_reply_response(email_content)
  end
end
