class Movie < ApplicationRecord
  has_and_belongs_to_many :users

  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy
end
