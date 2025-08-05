class GenerateInitialMessageJob < ApplicationJob
  queue_as :default

  def perform(goal_id, service_class: GoalMessageService)
    goal = Goal.find(goal_id)

    return if goal.goal_messages.any?

    GoalMessageService.new(goal).generate_initial_message
  rescue => e
    Rails.logger.error "Failed to generate initial message for goal #{goal_id}: #{e.message}"
  end
end
