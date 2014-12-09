class AddIndexes < ActiveRecord::Migration
  def change
     add_index :registrations, [:user_id, :meetup_id], unique: true
  end
end
