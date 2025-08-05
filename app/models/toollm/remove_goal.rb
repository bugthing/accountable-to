class Toollm::RemoveGoal < RubyLLM::Tool
  description "Removes a Goal. Provide the goal ID to remove it."
  param(
    :goal_id,
    required: true,
    type: :integer,
    desc: "the ID of the Goal you want removed"
  )

  def execute(goal_id:)
    goal = Goal.find_by(id: goal_id)
    if goal.blank?
      {error: "Goal with ID #{goal_id} not found."}
    elsif goal.remove!
      {success: true}
    else
      {error: "Failed to remove Goal with ID #{goal_id}."}
    end
  rescue => e
    {error: e.message}
  end
end
