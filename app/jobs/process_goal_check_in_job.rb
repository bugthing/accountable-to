class ProcessGoalCheckInJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.find(goal_id)
    GoalMessageService.new(goal).generate_followup_message
  end
end
