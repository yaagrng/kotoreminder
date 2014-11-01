class CreateReminders < ActiveRecord::Migration
  def change
    create_table :reminders do |t|
      t.integer :user_id
      t.integer :uid
      t.string :content
      t.integer :time
      t.string :name

      t.timestamps
    end
    add_index :reminders, [:uid, :time, :content], unique: true
  end
end
