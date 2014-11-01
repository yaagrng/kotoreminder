class Reminder < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('time') }
  validates :content, presence: true
end
