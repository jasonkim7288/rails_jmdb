# frozen_string_literal: true

class MoviesReflex < ApplicationReflex
  def add_to_watchlist
    current_user_id = element.dataset[:user_id]
    current_movie_id = element.dataset[:movie_id]
    watch_list = MoviesUser.find_by(user_id: current_user_id, movie_id: current_movie_id)
    if watch_list
      watch_list.destroy
    else
      MoviesUser.create(user_id: current_user_id, movie_id: current_movie_id)
    end
  end
end
