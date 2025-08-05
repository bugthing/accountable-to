require "test_helper"

class GenerateGoalTitleJobTest < ActiveJob::TestCase
  test "job finds goals, user RubyLLM to generate title and store again goal" do
    goal = goals(:one)

    VCR.use_cassette("generate_goal_title_01") do
      assert_nothing_raised do
        GenerateGoalTitleJob.perform_now(goal.id)
      end
    end

    goal.reload
    assert_equal goal.title, "Exercise Daily"
  end
end
