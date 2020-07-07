class ChangeUserRatingInRatings < ActiveRecord::Migration[6.0]
  def change
    change_column :ratings, :user_rating, :integer, null: false
  end
end
