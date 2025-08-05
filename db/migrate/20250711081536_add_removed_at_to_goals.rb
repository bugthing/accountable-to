class AddRemovedAtToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :removed_at, :datetime, null: true, comment: "Timestamp when the goal was marked to be removed"
    add_index :goals, :removed_at
  end
end
