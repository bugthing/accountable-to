class HomeController < ApplicationController
  def index
    @user = User.new
  end

  def signup
    existing_user = User.find_by(email: user_params[:email])

    if existing_user
      # User already exists, show magic link option
      @existing_user = existing_user
      @user = User.new(user_params) # Keep form filled
      render :index, status: :unprocessable_content
    else
      # New user signup flow
      @user = User.new(user_params)

      if @user.save
        UserMailer.confirmation_email(@user).deliver_later
        redirect_to root_path, notice: "Thank you! Please check your email to confirm your account."
      else
        render :index, status: :unprocessable_content
      end
    end
  end

  def send_magic_link
    user = User.find_by(email: params[:email])

    if user&.confirmed?
      user.generate_magic_link!
      UserMailer.magic_link_email(user).deliver_later
      redirect_to root_path, notice: "Magic link sent! Check your email to login."
    else
      redirect_to root_path, alert: "Account not found or not confirmed."
    end
  end

  def privacy_policy
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end
end
