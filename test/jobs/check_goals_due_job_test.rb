require "test_helper"

class CheckGoalsDueJobTest < ActiveJob::TestCase
  test "enqueues ProcessGoalCheckInJob for goals due for checkin" do
    goal = goals(:one)

    goal.goal_messages.create!(
      role: "assistant",
      content: "Test message",
      created_at: 2.days.ago
    )

    assert_enqueued_with(job: ProcessGoalCheckInJob, args: [goal.id]) do
      CheckGoalsDueJob.perform_now
    end
  end

  test "does not enqueue jobs for goals not due for checkin" do
    goal = goals(:one)

    goal.goal_messages.create!(
      role: "assistant",
      content: "Test message",
      created_at: 1.hour.ago
    )

    assert_no_enqueued_jobs(only: ProcessGoalCheckInJob) do
      CheckGoalsDueJob.perform_now
    end
  end
end
