require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @unconfirmed_user = users(:three)
  end

  test "should confirm user with valid token" do
    @unconfirmed_user.update!(
      confirmation_token: "valid_token",
      confirmation_token_generated_at: Time.current
    )

    get confirm_user_path(@unconfirmed_user.confirmation_token)

    assert_redirected_to confirmed_path
    assert @unconfirmed_user.reload.confirmed?
    assert session[:user_id] == @unconfirmed_user.id
  end

  test "should redirect with alert for invalid confirmation token" do
    get confirm_user_path("invalid_token")

    assert_redirected_to root_path
    assert_equal "Invalid confirmation link.", flash[:alert]
  end

  test "should redirect to dashboard if user already confirmed" do
    get confirm_user_path(@user.confirmation_token)

    assert_redirected_to dashboard_path
    assert_equal "Your account is already confirmed.", flash[:notice]
    assert session[:user_id] == @user.id
  end

  test "should redirect with alert for expired confirmation token" do
    @unconfirmed_user.update!(
      confirmation_token: "expired_token",
      confirmation_token_generated_at: 2.hours.ago
    )

    get confirm_user_path(@unconfirmed_user.confirmation_token)

    assert_redirected_to root_path
    assert_equal "Confirmation link has expired. Please sign up again.", flash[:alert]
  end

  test "should show confirmed page for logged in user" do
    log_in(@user)
    get confirmed_path

    assert_response :success
  end

  test "should redirect to root if not logged in for confirmed page" do
    get confirmed_path

    assert_redirected_to root_path
  end

  test "should login user with valid magic link token" do
    @user.generate_magic_link!

    get magic_login_path(@user.magic_link_token)

    assert_redirected_to dashboard_path
    assert_equal "Welcome back! You've been logged in successfully.", flash[:notice]
    assert session[:user_id] == @user.id
    assert_nil @user.reload.magic_link_token
  end

  test "should redirect with alert for invalid magic link token" do
    get magic_login_path("invalid_token")

    assert_redirected_to root_path
    assert_equal "Invalid login link.", flash[:alert]
  end

  test "should redirect with alert for expired magic link token" do
    @user.update!(
      magic_link_token: "expired_token",
      magic_link_token_generated_at: 2.hours.ago
    )

    get magic_login_path(@user.magic_link_token)

    assert_redirected_to root_path
    assert_equal "Login link has expired. Please request a new one.", flash[:alert]
  end

  test "should redirect with alert for unconfirmed user with magic link" do
    @unconfirmed_user.generate_magic_link!

    get magic_login_path(@unconfirmed_user.magic_link_token)

    assert_redirected_to root_path
    assert_equal "Account not confirmed. Please confirm your email first.", flash[:alert]
  end

  test "should logout user and redirect to root" do
    log_in(@user)

    delete logout_path

    assert_redirected_to root_path
    assert_equal "You have been logged out.", flash[:notice]
    assert_nil session[:user_id]
  end

  test "should handle logout when not logged in" do
    delete logout_path

    assert_redirected_to root_path
    assert_equal "You have been logged out.", flash[:notice]
  end

  private

  def log_in(user)
    user.generate_magic_link!
    get magic_login_path(user.magic_link_token)
  end
end
