class CreateGoalMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :goal_messages do |t|
      t.references :goal, null: false, foreign_key: true
      t.string :role
      t.text :content

      t.timestamps
    end
  end
end
