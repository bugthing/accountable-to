class CreateToolCall < ActiveRecord::Migration[8.0]
  def change
    create_table :tool_calls do |t|
      t.references :goal_message, null: false, foreign_key: true
      t.string :tool_call_id, null: false, index: {unique: true} # Provider's ID for the call
      t.string :name, null: false
      t.json :arguments, default: {}
      t.timestamps
    end
  end
end
