class CheckGoalsDueJob < ApplicationJob
  queue_as :default

  def perform
    Goal.due_for_checkin.find_each do |goal|
      ProcessGoalCheckInJob.perform_later(goal.id)
    end
  end
end
