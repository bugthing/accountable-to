require "test_helper"

class GenerateInitialMessageJobTest < ActiveJob::TestCase
  def setup
    @user = User.create!(email: "test@example.com")
    @goal = @user.goals.create!(
      description: "Read 20 pages of a book every day to expand knowledge",
      frequency: "daily"
    )

    @service_constructor_spy = Spy.on(GoalMessageService, :new).and_call_through
    @service_method_spy = Spy.on_instance_method(GoalMessageService, :generate_initial_message)
  end

  test "perform generates initial message for goal" do
    GenerateInitialMessageJob.perform_now(@goal.id)

    assert(@service_constructor_spy.has_been_called_with?(@goal))
    assert(@service_method_spy.has_been_called?)
  end

  test "perform skips if messages already exist" do
    @goal.goal_messages.create!(role: "system", content: "Existing message")

    GenerateInitialMessageJob.perform_now(@goal.id)

    refute(@service_constructor_spy.has_been_called?)
  end

  test "perform handles errors gracefully" do
    Spy.mock(Logger).tap do |logger_mock|
      @logger_constructor_spy = Spy.on(Rails, :logger).and_return(logger_mock)
      @logger_spy = Spy.on(logger_mock, :error)
    end

    assert_nothing_raised do
      GenerateInitialMessageJob.perform_now("")
    end

    assert_match(/Failed to generate initial message for goal/, @logger_spy.calls.first.args.first)
  end
end
