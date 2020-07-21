class MoviesController < ApplicationController
  before_action :authenticate_user!, only: [:mymovies, :myratings]
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  before_action :log_comment

  CAROUSEL_NUM = 5

  def search
    # convert searching text to url query format
    searchable_name = CGI.escape(params[:search_text_movie])

    # make omdb api url
    req_url = "http://www.omdbapi.com/?apikey=#{Rails.application.credentials.dig(:omdb, :api_key)}&s=#{searchable_name}"

    # get request to omdb api
    response = HTTParty.get(req_url)

    # get the results
    json_result = JSON.parse(response.body, { symbolized_names: true})

    @movies = []
    @avg_ratings = {}
    if json_result["Response"] == "True"
      result_movies = [*json_result["Search"]]
      result_movies.each do |result_movie|
        next if result_movie["Poster"] == "N/A"
        next if result_movie["Type"] != "movie" && result_movie["Type"] != "series"
        movie = Movie.find_by(omdb_id: result_movie["imdbID"])
        if !movie
          movie = Movie.new
          movie.title = result_movie["Title"]
          movie.omdb_id = result_movie["imdbID"]
          movie.category = result_movie["Type"]
          movie.poster = (result_movie["Poster"] == "N/A") ? "https://images.unsplash.com/photo-1581905764498-f1b60bae941a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=700&q=80" : result_movie["Poster"]

          # get more information for each omdbID
          req_url = "http://www.omdbapi.com/?apikey=#{Rails.application.credentials.dig(:omdb, :api_key)}&i=#{movie[:omdb_id]}&plot=full"
          response = HTTParty.get(req_url)
          json_result = JSON.parse(response.body, { symbolized_names: true})
          if json_result["Response"] == "True"
            movie.released = json_result["Released"] == "N/A" ? DateTime.new((json_result["Year"].split("–")[0]).to_i, 6, 1) : DateTime.parse(json_result["Released"])
            movie.rated = json_result["Rated"] == "N/A" ? "ALL" : json_result["Rated"]
            movie.runtime = json_result["Runtime"]
            movie.genre = json_result["Genre"]
            movie.director = json_result["Director"]
            movie.actors = json_result["Actors"]
            movie.plot = json_result["Plot"]
            movie.imdb_rating = 0

            # If there is Internet Movie Datebase rating, store it
            if json_result["Ratings"]
              rating_info = json_result["Ratings"].find {|m| m["Source"] == "Internet Movie Database"}
              if rating_info
                movie.imdb_rating = rating_info["Value"].split("/")[0].to_f.round(1)
              end
            end
            movie.user_rating = 0
          else
            movie.released = result_movie["Year"]
          end
          # save to the database
          movie.save
        end
        # for display
        @avg_ratings[movie.id] = calculate_avg_rating(movie)
        @movies.push(movie)
      end
    end
  end

  def index
    @movies = Movie.all.order("imdb_rating DESC").paginate(page: params[:page], per_page: 12)

    # pick up 15 random(for now) movies and use them for Carousel
    @avg_ratings_random = {}
    if @movies.count >= CAROUSEL_NUM * 3
      random_movies_total = Movie.all.order("RANDOM()").limit(CAROUSEL_NUM * 3)
      @random_movies = Array.new(3) {Array.new(CAROUSEL_NUM)}
      random_movies_total.each_slice(CAROUSEL_NUM).with_index do |mvs, i|
        @random_movies[i] = mvs
        mvs.each do |mv|
          @avg_ratings_random[mv.id] = calculate_avg_rating(mv)
        end
      end
    else
      @random_movies = nil
    end

    # calculate average rating for each movie
    @avg_ratings = {}
    @movies.each do |movie|
      @avg_ratings[movie.id] = calculate_avg_rating(movie)
    end
  end

  def show
    redirect_to movies_path if !@movie
    @comment = Comment.new
    @comments = @movie.comments.order("created_at DESC")
    @watchlist_added = (user_signed_in? && current_user.movies.find_by_id(@movie.id)) ? true : false
    if user_signed_in?
      @rating = @movie.ratings.find_by(user_id: current_user.id)
    else
      @rating = nil
    end

    # calculate average rating for each movie
    @avg_rating = calculate_avg_rating(@movie)
  end

  def destroy
    @movie.destroy
    redirect_to movies_path
  end

  def mymovies
    @movies = current_user.movies.order("created_at DESC").includes(:ratings).includes(:users)
    set_ratings_and_watchlist_addeds
  end

  def myratings
    benchmark "<myratings duration>" do
      # reduce the number of db access by adding "includes"
      # @movies = Movie.joins(:ratings).where(ratings: {user_id: current_user.id})
      @movies = Movie.joins(:ratings).where(ratings: {user_id: current_user.id}).includes(:ratings).includes(:users)
      # @movies = []
      # ratings = current_user.ratings.order("created_at DESC").includes(:movie)
      # ratings.each do |rating|
      #   @movies.push rating.movie
      # end
      set_ratings_and_watchlist_addeds
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find_by_id(params[:id])
    end

    def log_comment
      puts "-----------------------"
      puts controller_name + action_name
      puts "-----------------------"
    end

    def set_ratings_and_watchlist_addeds
      @watchlist_addeds = {}
      @avg_ratings = {}
      @movie_rating_current_user = {}
      @movies.preload(:users).each do |movie|
        # check if each movie is watchlist added
        # @watchlist_addeds[movie.id] = movie.users.find_by_id(current_user.id) ? true : false
        @watchlist_addeds[movie.id] = movie.users.filter{|user| user.id == current_user.id} != [] ? true : false
        # calculate average rating for each movie
        @avg_ratings[movie.id] = calculate_avg_rating(movie)
        # store movie rating for current user
        # @movie_rating_current_user[movie.id] = movie.ratings.find_by(user_id: current_user.id)
        @movie_rating_current_user[movie.id] = movie.ratings.filter {|rating| rating.user_id == current_user.id}[0]
      end
    end

    # calculate average rating including imdb rating and user ratings
    def calculate_avg_rating(movie)
      total_user_rating = movie.ratings.inject(0) {|result, rating| result + rating.user_rating}
      return ((movie.imdb_rating + total_user_rating) / (movie.ratings.length + 1)).round(1)
    end
end
