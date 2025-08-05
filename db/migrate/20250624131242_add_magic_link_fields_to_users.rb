class AddMagicLinkFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :magic_link_token, :string
    add_column :users, :magic_link_token_generated_at, :datetime
  end
end
