class CreateRegistration < ActiveRecord::Migration
  def change
    create_table :registrations do |table|
      table.integer :user_id, null: false
      table.integer :meetup_id, null: false

      table.timestamps
    end
  end
end
