class Meetup < ActiveRecord::Base
  has_many :registrations
  has_many :users, through: :registrations
  has_many :comments


end
