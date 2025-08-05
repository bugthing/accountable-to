require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user is invalid without email" do
    user = User.new(email: nil)
    refute user.valid?
  end

  test "user is invalid with an invalid email" do
    user = User.new(email: "ben@")
    refute user.valid?
  end

  test "user can on have 2 goals" do
    user = users(:three)
    user.goals.create!(description: "Goal 1111111111111", frequency: "daily")

    refute user.at_goal_limit?
    assert user.valid?

    user.goals.create!(description: "Goal 2222222222222", frequency: "daily")

    assert user.at_goal_limit?
    assert user.valid?

    user.goals.build(description: "Goal 3333333333333", frequency: "daily")

    assert user.at_goal_limit?
    refute user.valid?
  end

  test "when confirm, then confirmed? returns true and we know when and we remove the token" do
    user = User.create!(email: "test@example.com", confirmation_token: "123abc")

    user.confirm!

    assert user.confirmed?
    assert_not_nil user.confirmed_at
    assert_nil user.confirmation_token
  end

  test "when we generate a magic link, then we can check if it is expired" do
    user = User.create!(email: "test@example.com")

    user.generate_magic_link!

    assert_not_nil user.magic_link_token

    refute user.magic_link_expired?
    travel_to(1.hour.from_now + 1) do
      assert user.magic_link_expired?
    end

    user.clear_magic_link!

    assert_nil user.magic_link_token
  end
end
