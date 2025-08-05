require "telegram/bot"

class TelegramMessageHandler
  def initialize(bot)
    @bot = bot
  end

  def handle(message)
    chat_id = message.chat.id
    message_text = message.try(:text)
    return unless message_text.present?

    if message_text.start_with?("/start")

      if (matched = /^\/start\s+(?<token>.+)$/i.match(message.text))
        goal = Goal.find_by(telegram_token: matched[:token])
        if goal
          clear_chat_id(chat_id)
          update_chat_id(chat_id, goal)

          @bot.api.send_message(chat_id:, text: "Thanks #{goal.user.email}, you're now connected!")
        else
          @bot.api.send_message(chat_id:, text: "Sorry, I could not link you to a goal.")
        end
      else
        @bot.api.send_message(chat_id:, text: "Sorry, that wont work")
      end

    elsif message_text.start_with?("/stop")
      @bot.api.send_message(chat_id:, text: "Ok, bye")
      clear_chat_id(message.chat.id)
      Goal.where(telegram_chat_id: chat_id).update_all(telegram_chat_id: nil)
    else
      goal = Goal.find_by(telegram_chat_id: chat_id)
      if goal
        send_last_message(goal)
      else
        @bot.api.send_message(chat_id:, text: "Sorry, I couldn't find your goal. Please use /start with your goal token to connect.")
      end
    end
  end

  private

  def send_last_message(goal)
    return unless goal.telegram_chat_id.present?

    @bot.api.send_message(chat_id: goal.telegram_chat_id, text: <<~MESSAGE)
      #{goal.goal_messages.last&.content || "No messages yet."}
    MESSAGE
  end

  def update_chat_id(chat_id, goal)
    goal.update!(telegram_chat_id: chat_id)
  end

  def clear_chat_id(chat_id)
    Goal.where(telegram_chat_id: chat_id).update_all(telegram_chat_id: nil)
  end
end
