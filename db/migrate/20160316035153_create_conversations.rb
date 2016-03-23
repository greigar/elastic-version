class CreateConversations < ActiveRecord::Migration
  def change
    create_table :conversations do |t|
      t.string :state
      t.text :body

      t.timestamps null: false
    end
  end
end
