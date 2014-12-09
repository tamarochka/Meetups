class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :meetup
  has_one :meetup
  has_one :user
end
