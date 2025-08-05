require "test_helper"

class GoalResponsesMailboxTest < ActionMailbox::TestCase
  include ActiveJob::TestHelper

  setup do
    @goal = goals(:one)
    @user = @goal.user
    @goal.update!(email_token: "test-token-123")
  end

  test "processes email with valid goal token and strips reply" do
    email_content = "I went for a 45-minute run today and feel great!"

    inbound_email = create_inbound_email_from_mail(
      to: "goal-test-token-123@accountable.to",
      from: @user.email,
      subject: "Re: Check-in for your goal",
      body: <<~EMAIL
        #{email_content}
        On 31/32/1923, noreply@accountable.to wrote:
        some previous message content
        more previous message content
      EMAIL
    )

    assert_enqueued_with(job: GenerateAssistantResponseJob, args: [@goal.id, email_content]) do
      inbound_email.route
    end
  end

  test "processes email with valid goal token and multipart message" do
    email_content = "I went for a 45-minute run today and feel great!"
    inbound_email = create_inbound_email_from_mail(
      from: @user.email,
      to: "goal-test-token-123@accountable.to",
      subject: "Re: Check-in for your goal"
    ) do
      text_part { it.body(email_content) }
      html_part { it.body(email_content) }
    end

    assert_enqueued_with(job: GenerateAssistantResponseJob, args: [@goal.id, email_content]) do
      inbound_email.route
    end
  end

  test "handles email with invalid goal token gracefully" do
    inbound_email = create_inbound_email_from_mail(
      to: "goal-invalid-token@accountable.to",
      from: @user.email,
      subject: "Re: Check-in for your goal",
      body: "This should not create a message"
    )

    assert_no_enqueued_jobs only: GenerateAssistantResponseJob do
      inbound_email.route
    end

    assert inbound_email.bounced?
  end
end
