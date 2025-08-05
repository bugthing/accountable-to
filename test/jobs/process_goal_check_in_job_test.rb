require "test_helper"

class ProcessGoalCheckInJobTest < ActiveJob::TestCase
  setup do
    @goal = goals(:one)
  end

  test "finds the correct goal and calls the service to generate message and send mailer" do
    VCR.use_cassette("generate_followup_message_01") do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["GoalMailer", "assistant_message", "deliver_now", {args: [@goal]}]) do
        ProcessGoalCheckInJob.perform_now(@goal.id)
      end
    end
  end
end
