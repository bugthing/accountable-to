require "test_helper"

class GoalTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "validations" do
    user = User.create!(email: "test@example.com")
    Goal.create!(user:, title: "Goal 1", frequency: "daily", description: "A goal description")
    Goal.create!(user:, title: "Goal 2", frequency: "weekly", description: "Another goal description")

    goal3 = Goal.new(user:, title: "Goal 3", frequency: "daily", description: "Goal description")
    refute goal3.valid?
    assert_includes goal3.errors[:base], "You can only have a maximum of 2 goals"
  end

  test ".active scope" do
    goal = goals(:one)

    assert_includes Goal.due_for_checkin, goal

    goal.remove!

    refute Goal.due_for_checkin.include?(goal)
  end

  test ".due_for_checkin scope" do
    goal = goals(:one)
    message = goal.goal_messages.create!(role: "system", content: "about goal 1", created_at: 0.days.ago)

    refute Goal.due_for_checkin.include?(goal)

    message.update!(created_at: 1.day.ago)

    assert_includes Goal.due_for_checkin, goal

    goal.remove!

    refute Goal.due_for_checkin.include?(goal)
  end

  test "#frequency_description" do
    goal = goals(:one)
    assert_equal "Check in daily", goal.frequency_description

    goal.frequency = "weekly"
    assert_equal "Check in weekly", goal.frequency_description

    goal.frequency = "monthly"
    assert_equal "Check in monthly", goal.frequency_description
  end

  test "#goal_messages_for_history" do
    goal = goals(:one)
    user_message = goal.goal_messages.create!(content: "User message", role: :user)
    assistant_message = goal.goal_messages.create!(content: "Assistant message", role: :assistant)

    history = goal.goal_messages_for_history
    assert_includes history, user_message
    assert_includes history, assistant_message
    assert_equal 2, history.count
  end

  test "#most_recent_assistant_message" do
    goal = goals(:one)
    goal.goal_messages.create!(content: "First assistant message", role: :assistant)
    assistant_message2 = goal.goal_messages.create!(content: "Second assistant message", role: :assistant)

    most_recent = goal.most_recent_assistant_message
    assert_equal assistant_message2, most_recent
  end

  test "#due_for_checkin?" do
    goal = goals(:one)
    message = goal.goal_messages.create!(role: "system", content: "about goal 1", created_at: 0.days.ago)

    refute goal.due_for_checkin?

    message.update(created_at: 1.day.ago)
    assert goal.due_for_checkin?

    goal.update(frequency: "weekly")
    refute goal.due_for_checkin?
    message.update(created_at: 8.days.ago)
    assert goal.due_for_checkin?

    goal.update(frequency: "monthly")
    refute goal.due_for_checkin?
    message.update(created_at: 32.days.ago)
    assert goal.due_for_checkin?
  end

  test "#last_message_at" do
    goal = goals(:one)
    assert_nil goal.last_message_at

    goal.goal_messages.create!(content: "First message", role: :user)
    assert_not_nil goal.last_message_at
  end

  test "#reply_email_address" do
    goal = goals(:one)
    goal.update!(email_token: "12345")
    assert_equal goal.reply_email_address, "goal-12345@#{Rails.configuration.action_mailer.default_url_options[:host]}"
  end

  test "#broadcast_message_history_append" do
    goal = goal_messages(:two).goal
    assert_turbo_stream_broadcasts([goal, :message_history]) do
      goal.broadcast_message_history_append
    end
  end

  test "#remove!" do
    goal = goals(:one)

    goal.remove!

    assert goal.removed_at
    assert goal.removed?
  end
end
