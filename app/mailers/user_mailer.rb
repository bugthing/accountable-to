class UserMailer < ApplicationMailer
  def confirmation_email(user)
    @user = user
    @confirmation_url = confirm_user_url(@user.confirmation_token)

    mail(
      to: @user.email,
      subject: "Welcome to Accountable To - Confirm your email"
    )
  end

  def magic_link_email(user)
    @user = user
    @magic_login_url = magic_login_url(@user.magic_link_token)

    mail(
      to: @user.email,
      subject: "Your secure login link for Accountable To"
    )
  end
end
