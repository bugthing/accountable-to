class GenerateGoalTitleJob < ApplicationJob
  queue_as :default

  def perform(goal_id)
    goal = Goal.find(goal_id)
    return if goal.title.present?

    title = generate_title_from(goal.description)
    goal.update!(title: title)
  end

  private

  def generate_title_from(description)
    chat = RubyLLM.chat
    response = chat.ask(<<~PROMPT)
      the following is a description of someones goal, please respond with a concise title for the goal, it must be less than 50 characters

      #{description}
    PROMPT
    response.content.strip.gsub(/\s+/, " ")
  end
end
