require "test_helper"

class GoalMessageServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = User.create!(
      email: "test@example.com"
    )
    @goal = @user.goals.create!(
      description: "Learn to play guitar by practicing 30 minutes daily",
      frequency: "daily"
    )
    @service = GoalMessageService.new(@goal)
  end

  test "generate_initial_message creates system, user, and assistant messages" do
    VCR.use_cassette("generate_initial_message_01") do
      @service.generate_initial_message
    end

    assert_equal 3, @goal.goal_messages.count

    system_msg = @goal.goal_messages.by_role("system").first
    assert system_msg.present?
    assert_match(/You are an AI accountability coach/, system_msg.content)

    user_msg = @goal.goal_messages.by_role("user").first
    assert user_msg.present?
    assert_match(/Learn to play guitar by practicing/, user_msg.content)

    assistant_msg = @goal.goal_messages.by_role("assistant").first
    assert assistant_msg.present?
    assert_match(/fantastic/, assistant_msg.content)
  end

  test "generate_initial_message sends assistant email" do
    VCR.use_cassette("generate_initial_message_01") do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["GoalMailer", "assistant_message", "deliver_now", {args: [@goal]}]) do
        @service.generate_initial_message
      end
    end
  end

  test "generate_followup_message records the user message and ai response" do
    @goal.goal_messages.create!(role: "system", content: "You are an AI accountability coach")
    @goal.goal_messages.create!(role: "user", content: "I just set the goal to learn guitar")
    @goal.goal_messages.create!(role: "assistant", content: "That's fantastic!")

    VCR.use_cassette("generate_followup_message_02") do
      @service.generate_followup_message
    end

    assert_equal 6, @goal.goal_messages.count

    new_user_msg = @goal.goal_messages.by_role("user").second
    assert_match(/I am doing my daily check in/, new_user_msg.content)

    new_assistant_msg = @goal.goal_messages.by_role("assistant").last
    assert_match(/Hello/, new_assistant_msg.content)
  end

  test "generate_followup_message sends assistant email" do
    VCR.use_cassette("generate_followup_message_02") do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["GoalMailer", "assistant_message", "deliver_now", {args: [@goal]}]) do
        @service.generate_followup_message
      end
    end
  end

  test "generate_reply_response records ai the content from the reply" do
    @goal.goal_messages.create!(role: "system", content: "You are an AI accountability coach")
    @goal.goal_messages.create!(role: "user", content: "I just set the goal to learn guitar")
    @goal.goal_messages.create!(role: "assistant", content: "Nice one, how will you start?")

    VCR.use_cassette("generate_reply_response_01") do
      @service.generate_reply_response("I will learn 1 chord, A major, today")
    end

    assert_equal 6, @goal.goal_messages.count

    new_user_msg = @goal.goal_messages.by_role("user").second
    assert_match(/I will learn 1 chord/, new_user_msg.content)

    new_assistant_msg = @goal.goal_messages.by_role("assistant").last
    assert_match(/chord a day is a great way/, new_assistant_msg.content)
  end

  test "generate_reply_response sends assistant email" do
    VCR.use_cassette("generate_reply_response_01") do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob, args: ["GoalMailer", "assistant_message", "deliver_now", {args: [@goal]}]) do
        @service.generate_reply_response("I will learn 1 chord, A major, today")
      end
    end
  end

  test "generate_reply_response can use a tool to remove goal" do
    VCR.use_cassette("generate_reply_response_02") do
      assert_difference("ToolCall.count") do
        @service.generate_reply_response("I have completed my goal!, please remove this")
      end
    end

    @goal.reload

    assert @goal.removed?
    assert_equal ToolCall.all.last.message.chat, @goal
  end
end
