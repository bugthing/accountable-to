class AddTelegramFieldsToGoals < ActiveRecord::Migration[8.0]
  def change
    add_column :goals, :telegram_token, :string
    add_column :goals, :telegram_chat_id, :string
    add_index :goals, :telegram_token, unique: true
    add_index :goals, :telegram_chat_id, unique: true

    remove_column :users, :telegram_token, :string, if_exists: true
    remove_column :users, :telegram_chat_id, :string, if_exists: true
  end
end
