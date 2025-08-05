require "test_helper"

class GoalMessageTest < ActiveSupport::TestCase
  test "goal message is invalid without role" do
    goal_message = GoalMessage.new(
      goal: goals(:one),
      content: "hi",
      role: nil,
      created_at: Time.current
    )
    refute goal_message.valid?
  end

  test ".chronological returns messages in order of creation" do
    goal = goals(:one)
    message1 = GoalMessage.create!(goal: goal, content: "First message", role: "user", created_at: 2.hours.ago)
    message2 = GoalMessage.create!(goal: goal, content: "Second message", role: "assistant", created_at: 1.hour.ago)

    assert_equal [message1, message2], GoalMessage.where(goal:).chronological.to_a
  end
end
