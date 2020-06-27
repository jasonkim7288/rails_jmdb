class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]

  def create
    puts "***************"
    p comment_params
    @movie = Movie.find(params[:movie_id])
    @movie.comments.create(comment_params)
    redirect_to @movie
  end

  def update
  end

  def destroy
    @movie = @comment.movie
    @comment.destroy
    redirect_to @movie
  end

  private
    def set_comment
      @comment = Comment.find(params[:id])
    end

    def comment_params
      params.require(:comment).permit(:body, :movie_id)
    end
end
