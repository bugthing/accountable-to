class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def logged_in?
    current_user.present?
  end
  helper_method :logged_in?

  def log_in(user)
    session[:user_id] = user.id
  end

  def log_out
    session[:user_id] = nil
    @current_user = nil
  end

  def require_login
    unless logged_in?
      redirect_to root_path, alert: "Please sign up and confirm your email to access this page."
    end
  end
end
