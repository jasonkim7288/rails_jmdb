class RemoveTypeFromMovies < ActiveRecord::Migration[6.0]
  def change
    remove_column :movies, :type, :string
  end
end
