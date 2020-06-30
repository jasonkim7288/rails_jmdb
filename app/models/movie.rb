class Movie < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :users
  has_many :ratings
  has_many :users, through: :ratings

end
