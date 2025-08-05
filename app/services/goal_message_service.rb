class GoalMessageService
  def initialize(goal)
    @goal = goal
  end

  def generate_initial_message
    @goal.with_instructions(initial_instruction_prompt)
    @goal.ask(initial_user_prompt)
    GoalMailer.assistant_message(@goal).deliver_later
    @goal.broadcast_message_history_append
  end

  def generate_followup_message
    @goal.with_instructions(followup_instruction_prompt)
    @goal.ask(followup_user_prompt)
    GoalMailer.assistant_message(@goal).deliver_later
    @goal.broadcast_message_history_append
  end

  def generate_reply_response(reply_content)
    @goal.with_instructions(reply_instruction_prompt)

    remove_tool = Toollm::RemoveGoal.new
    @goal.with_tool(remove_tool)

    @goal.ask(reply_content)

    GoalMailer.assistant_message(@goal).deliver_later
    @goal.broadcast_message_history_append
  end

  private

  def instruction_prompt_prefix
    <<~PROMPT
      You are an AI accountability coach helping someone achieve their personal goals. Your role is to:

      1. Provide encouragement and motivation
      2. Ask thoughtful questions about their progress
      3. Offer practical advice and strategies
      4. Help them overcome obstacles and challenges
      5. Celebrate their wins, no matter how small
      6. Keep them focused on their goal

      Be supportive, empathetic and encouraging in your responses.
      The user has set a goal with #{@goal.frequency} check-ins.
    PROMPT
  end

  def initial_instruction_prompt
    <<~PROMPT
      #{instruction_prompt_prefix}
      You receive will the goal the person wants to achieve, you must respond with a message that helps them start off achieving their goal.
    PROMPT
  end

  def followup_instruction_prompt
    <<~PROMPT
      #{instruction_prompt_prefix}
      This is a checkin. Given the users goal and message history, you must respond with a message that helps them continue achieving their goal.
    PROMPT
  end

  def reply_instruction_prompt
    <<~PROMPT
      #{instruction_prompt_prefix}
      Given the users goal and message history, you must respond to the message from the user.
      Your response must be pertinent to the goal and not include any other information.
      If the user suggests they have completed or wants to remove the goal, you must use the tool RemoveGoal(goal_id=#{@goal.id}) to remove the goal.
    PROMPT
  end

  def initial_user_prompt = @goal.description

  def followup_user_prompt
    <<~PROMPT
      Hello, I am doing my #{@goal.frequency} check in, please respond.
    PROMPT
  end
end
