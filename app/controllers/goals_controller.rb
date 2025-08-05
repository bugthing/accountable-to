class GoalsController < ApplicationController
  before_action :require_login

  def index
    @goals = current_user.goals.includes(:goal_messages).order(created_at: :desc)
  end

  def show
    @goal = current_user.goals.find(params[:id])
  end

  def new
    if current_user.at_goal_limit?
      redirect_to dashboard_path, alert: "You have reached the maximum of #{User::MAX_GOALS} goals."
    else
      @goal = current_user.goals.build
    end
  end

  def create
    @goal = current_user.goals.build(goal_params)

    if @goal.save
      redirect_to dashboard_path, notice: "Great! Your goal has been set up. We'll check in with you #{@goal.frequency}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    @goal = current_user.goals.find(params[:id])
    @goal.destroy
    redirect_to dashboard_path, notice: "Goal removed."
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "Goal not found."
  end

  private

  def goal_params
    params.require(:goal).permit(:description, :frequency)
  end
end
