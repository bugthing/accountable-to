require "test_helper"

class GoalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @goal = goals(:one)
    @other_user = users(:two)
    @other_goal = goals(:two)
  end

  test "should redirect to root when not logged in" do
    get goals_path
    assert_redirected_to root_path
    assert_equal "Please sign up and confirm your email to access this page.", flash[:alert]
  end

  test "should get index when logged in" do
    log_in(@user)
    get goals_path
    assert_response :success
    assert_includes @response.body, @goal.title
  end

  test "should show goal when logged in and is own goal" do
    log_in(@user)
    get goal_path(@goal)
    assert_response :success
    assert_includes @response.body, @goal.title
  end

  test "should not show other user's goal" do
    log_in(@user)
    get goal_path(@other_goal)
    assert_response :not_found
  end

  test "should get new when logged in and under goal limit" do
    log_in(@user)
    get new_goal_path
    assert_response :success
    assert_includes @response.body, "Tell me about the goal you would like to achieve."
  end

  test "should redirect to dashboard when at goal limit" do
    log_in(@user)
    @user.goals.create!(title: "Test Goal", description: "Test description", frequency: "daily")

    get new_goal_path
    assert_redirected_to dashboard_path
    assert_equal "You have reached the maximum of #{User::MAX_GOALS} goals.", flash[:alert]
  end

  test "should create goal with valid params" do
    log_in(@user)
    assert_difference("Goal.count") do
      post goals_path, params: {goal: {description: "Test goal description", frequency: "daily"}}
    end

    assert_redirected_to dashboard_path
    assert_equal "Great! Your goal has been set up. We'll check in with you daily.", flash[:notice]
  end

  test "should not create goal with invalid params" do
    log_in(@user)
    assert_no_difference("Goal.count") do
      post goals_path, params: {goal: {description: "short", frequency: "daily"}}
    end

    assert_response :unprocessable_content
    assert_includes @response.body, "is too short"
  end

  test "should destroy goal when logged in and is own goal" do
    log_in(@user)
    assert_difference("Goal.count", -1) do
      delete goal_path(@goal)
    end

    assert_redirected_to dashboard_path
    assert_equal "Goal removed.", flash[:notice]
  end

  test "should not destroy other user's goal" do
    log_in(@user)
    assert_no_difference("Goal.count") do
      delete goal_path(@other_goal)
    end
  end

  test "should handle goal not found gracefully" do
    log_in(@user)
    delete goal_path(id: 999999)
    assert_redirected_to dashboard_path
    assert_equal "Goal not found.", flash[:alert]
  end

  private

  def log_in(user)
    user.generate_magic_link!
    get magic_login_path(user.magic_link_token)
  end
end
