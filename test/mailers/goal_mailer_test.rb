require "test_helper"

class GoalMailerTest < ActionMailer::TestCase
  setup do
    @goal = goals(:one)
    @goal.update!(email_token: "test-token-123")
  end

  test "assistant_message" do
    email = GoalMailer.assistant_message(@goal)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [@goal.user.email], email.to
    assert_equal @goal.reply_email_address, email.reply_to.first
    assert_equal "Assistant message for: #{@goal.title}", email.subject
    assert_match @goal.title, email.html_part.body.to_s
    assert_match @goal.title, email.text_part.body.to_s
    assert_match "reply directly to this email", email.html_part.body.to_s
    assert_match "reply directly to this email", email.text_part.body.to_s
  end
end
