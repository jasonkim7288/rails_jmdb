class AddColumnsToMovies < ActiveRecord::Migration[6.0]
  def change
    add_column :movies, :released, :date
    add_column :movies, :rated, :string
    add_column :movies, :runtime, :string
    add_column :movies, :genre, :string
    add_column :movies, :director, :string
    add_column :movies, :actors, :string
    add_column :movies, :plot, :text
    add_column :movies, :user_rating, :decimal
    add_column :movies, :imdb_rating, :decimal
  end
end
