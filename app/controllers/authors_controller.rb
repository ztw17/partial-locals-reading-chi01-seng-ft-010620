class AuthorsController < ApplicationController
  def show
    @post = Author.find(params[:id])
  end

  def index
    @posts = Author.all
  end
end
