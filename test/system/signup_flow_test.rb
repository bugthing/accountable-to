require "application_system_test_case"

class SignupFlowTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  setup do
    VCR.insert_cassette(@NAME.to_s, record: :new_episodes)
  end

  teardown do
    VCR.eject_cassette
  end

  test "sign up then magic link then create 2 goals, delete 1" do
    visit root_path

    assert_selector "input[type=email]"
    assert_button "Get Started Free"

    test_email = "test@example.com"
    fill_in "user[email]", with: test_email
    click_button "Get Started Free"

    assert_current_path root_path
    assert_text "Thank you! Please check your email to confirm your account."

    user = User.find_by(email: test_email)
    assert user.present?
    assert user.confirmation_token.present?
    assert_not user.confirmed?

    # click confirmation link in email
    visit confirm_user_path(user.confirmation_token)

    assert_current_path confirmed_path
    assert_text "Email Confirmed!"
    assert_text "Welcome to Accountable To!"

    user.reload
    assert user.confirmed?

    click_link "Create My First Goal"

    assert_current_path new_goal_path
    assert_text "What is your Goal?"

    fill_in "goal[description]", with: "I want to exercise daily by running 30 minutes every morning"
    find("label", text: "Daily").click
    click_button "Create My Goal"

    assert_current_path dashboard_path
    assert_text "Great! Your goal has been set up. We'll check in with you daily."

    click_button "Logout"
    assert_current_path root_path
    assert_text "You have been logged out."

    visit dashboard_path
    assert_current_path root_path
    assert_text "Please sign up and confirm your email to access this page."

    fill_in "user[email]", with: user.email
    click_button "Get Started Free"

    assert_current_path root_path
    assert_text "This email is already registered!"

    click_button "Send Magic Link to Login"

    assert_text "Magic link sent! Check your email to login."

    # click the magic link from email
    user.reload
    visit magic_login_path(user.magic_link_token)

    assert_current_path dashboard_path
    assert_text "Welcome back! You've been logged in successfully."

    click_link "Add New Goal"
    fill_in "goal[description]", with: "I want to learn Spanish by practicing 15 minutes every day using language apps and conversing with native speakers"
    find("label", text: "Weekly").click
    click_button "Create My Goal"

    assert_current_path dashboard_path
    assert_text "Great! Your goal has been set up. We'll check in with you weekly."

    user.reload
    assert user.goals.any?

    # process background jobs manually in test
    user.goals.each do |goal|
      GenerateGoalTitleJob.perform_now(goal.id)
      GenerateInitialMessageJob.perform_now(goal.id)
    end

    user.reload
    assert user.goals.all? { it.title.present? }
    assert user.goals.all? { it.goal_messages.any? }

    goal = user.goals.last

    system_message = goal.goal_messages.by_role("system").first
    assert system_message.present?
    assert system_message.content.include?("accountability coach")

    user_message = goal.goal_messages.by_role("user").first
    assert user_message.present?
    assert user_message.content.include?("I want to learn")

    ai_message = goal.goal_messages.by_role("assistant").first
    assert ai_message.present?
    assert ai_message.content.length > 20

    assert_text "Goal limit reached (2/2)"
    assert_no_link "Add New Goal"
    click_link "View Details", match: :first

    accept_confirm do
      click_button "Delete this Goal"
    end

    assert_current_path dashboard_path
    assert_text "Goal removed"

    click_link "View Details"
    find("details.message-history").click

    refute_text "this is a test"

    ## here we were cheatng abit and directly create a test chat message and broadcast it to assert the UI updates
    ## ideally one would trigger this by interacting with the application (could send in email)
    # Goal.last.then do |goal|
    #  goal.goal_messages.create!(role: "assistant", content: "How does it feel having achieved your goal?")
    #  goal.broadcast_message_history_append
    # end
    ## now were are faking the receipt of an email regarding a goal
    perform_enqueued_jobs do
      Goal
        .last
        .then do |goal|
          Mail.new(
            to: goal.reply_email_address,
            from: goal.user.email,
            subject: "I just totally smashed it",
            body: "Got to my goal just now!"
          )
        end
        .then do |mail|
          ActionMailbox::InboundEmail.create_and_extract_message_id!(mail.to_s)
        end
        .then do |inbound_email|
          inbound_email.route
        end
    end

    assert_text "Great job reaching your goal"
  end
end
