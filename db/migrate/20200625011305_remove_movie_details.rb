class RemoveMovieDetails < ActiveRecord::Migration[6.0]
  def change
    drop_table :movie_details
  end
end
