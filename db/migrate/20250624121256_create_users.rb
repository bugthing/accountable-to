class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_token_generated_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :confirmation_token
  end
end
