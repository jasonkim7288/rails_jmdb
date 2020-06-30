class DropWatchlistsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :watchlists
  end
end
