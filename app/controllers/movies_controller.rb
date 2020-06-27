class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

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
        @movies.push(movie)
      end
    end

    p @movies

  end

  def index
    @movies = Movie.all.order("released DESC")
    # pick up 15 random(for now) movies and use them for Carousel
    if @movies.count >= CAROUSEL_NUM * 3
      random_movies_total = Movie.all.order("RANDOM()").limit(CAROUSEL_NUM * 3)
      @random_movies = Array.new(3) {Array.new(CAROUSEL_NUM)}
      random_movies_total.each_slice(CAROUSEL_NUM).with_index do |mvs, i|
        @random_movies[i] = mvs
      end
    else
      @random_movies = nil
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
  end

  def update
  end

  def destroy
    @movie.destroy
    redirect_to movies_path
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_movie
    @movie = Movie.find(params[:id])
  end

end
