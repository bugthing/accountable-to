class GoalResponsesMailbox < ApplicationMailbox
  before_processing :ensure_goal_exists

  def process
    GenerateAssistantResponseJob.perform_later(goal.id, clean_reply(extract_body))
  end

  private

  def goal
    @goal ||= Goal.find_by(email_token: email_token)
  end

  def email_token
    recipient = mail.to.first
    return nil unless recipient

    match = recipient.match(/goal-(?<token>[a-zA-Z0-9_-]+)@/)
    match ? match[:token] : nil
  end

  def ensure_goal_exists
    unless goal
      Rails.logger.warn "Goal not found for email token: #{email_token}"
      bounced!
    end
  end

  def extract_body
    if mail.multipart?
      mail.text_part&.decoded || mail.html_part&.decoded || ""
    else
      mail.body.decoded
    end
  end

  def clean_reply(text)
    reply_separator = /^(On\s.+?wrote:|>|\s*>+)/

    lines = text.lines
    cleaned_lines = lines.take_while { |line| !(line =~ reply_separator) }

    cleaned_lines.join.strip
  end
end
