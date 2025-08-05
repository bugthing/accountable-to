class CreateGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :goals do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :frequency

      t.timestamps
    end
  end
end
