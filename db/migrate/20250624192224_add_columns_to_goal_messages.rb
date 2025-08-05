class AddColumnsToGoalMessages < ActiveRecord::Migration[8.0]
  def change
    change_table :goal_messages do |t|
      t.string :model_id
      t.integer :input_tokens
      t.integer :output_tokens
      t.references :tool_call
    end
  end
end
