class AddTelegramIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :telegram_token, :string
    add_column :users, :telegram_chat_id, :string
    add_index :users, :telegram_token, unique: true
    add_index :users, :telegram_chat_id, unique: true
  end
end
