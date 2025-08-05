require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "confirmation_email" do
    user = users(:one)
    mail = UserMailer.confirmation_email(user)
    assert_equal "Welcome to Accountable To - Confirm your email", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@accountableto.com"], mail.from
    assert_match "Welcome to Accountable To", mail.body.encoded
  end
end
