class MoviesController < ApplicationController
  @@movies = []
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
      result_movies = json_result["Search"]
      result_movies.each do |result_movie|
        movie = {}
        movie[:title] = result_movie["Title"]
        movie[:omdb_id] = result_movie["imdbID"]
        movie[:type] = result_movie["Type"]
        movie[:poster] = (result_movie["Poster"] == "N/A") ? "https://images.unsplash.com/photo-1581905764498-f1b60bae941a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=700&q=80" : result_movie["Poster"]

        # get more information for each imdbID
        # req_url = "http://www.omdbapi.com/?apikey=#{Rails.application.credentials.dig(:omdb, :api_key)}&s=#{movie[:omdb_id]}"

        # for display
        @movies.push(movie)

        # for store to cookie
        if @@movies.filter {|m| m[:omdb_id] == movie[:omdb_id]} == []
          @@movies.unshift(movie)
        end
      end
    end
  end

  def index
    @movies = @@movies
    puts "**************************"
    p @movies
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
  end
end
