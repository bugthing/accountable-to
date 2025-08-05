class AddModelIdToGoal < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :model_id, :string
  end
end
