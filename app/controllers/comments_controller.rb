class CommentsController < ApplicationController
  before_action :set_comment, only: [:destroy]

  def create
    @movie = Movie.find(params[:movie_id])
    comment = @movie.comments.new(comment_params)
    comment.user_id = current_user.id
    comment.save
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
