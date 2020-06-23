class CreateMovies < ActiveRecord::Migration[6.0]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.string :omdb_id, null: false
      t.string :type, null: false
      t.string :poster, null: false

      t.timestamps
    end
  end
end
