class GoalMailer < ApplicationMailer
  def assistant_message(goal)
    @goal = goal
    mail(
      to: @goal.user.email,
      reply_to: @goal.reply_email_address,
      subject: "Assistant message for: #{goal.title}"
    )
  end
end
