class UsersController < ApplicationController
  def confirm
    @user = User.find_by(confirmation_token: params[:token])

    if @user.nil?
      redirect_to root_path, alert: "Invalid confirmation link."
    elsif @user.confirmed?
      log_in(@user)
      redirect_to dashboard_path, notice: "Your account is already confirmed."
    elsif @user.confirmation_expired?
      redirect_to root_path, alert: "Confirmation link has expired. Please sign up again."
    else
      @user.confirm!
      log_in(@user)
      redirect_to confirmed_path
    end
  end

  def confirmed
    redirect_to root_path unless current_user
  end

  def magic_login
    @user = User.find_by(magic_link_token: params[:token])

    if @user.nil?
      redirect_to root_path, alert: "Invalid login link."
    elsif @user.magic_link_expired?
      redirect_to root_path, alert: "Login link has expired. Please request a new one."
    elsif !@user.confirmed?
      redirect_to root_path, alert: "Account not confirmed. Please confirm your email first."
    else
      @user.clear_magic_link!
      log_in(@user)
      redirect_to dashboard_path, notice: "Welcome back! You've been logged in successfully."
    end
  end

  def logout
    log_out
    redirect_to root_path, notice: "You have been logged out."
  end
end
