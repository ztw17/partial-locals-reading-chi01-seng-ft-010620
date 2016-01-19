class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id])
    @author = @post.author
  end

  def index
    @posts = Post.all
  end
end
