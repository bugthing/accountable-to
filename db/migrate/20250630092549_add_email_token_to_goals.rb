class AddEmailTokenToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :email_token, :string
    add_index :goals, :email_token, unique: true
  end
end
