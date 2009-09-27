class PostsController < ApplicationController
  def index
    @author = params[:author]
    @tag = params[:tag]
    @posts = Post.find_latest(:tag => @tag, :include => :tags, :author => @author)

    respond_to do |format|
      format.html
      format.atom { render :layout => false }
    end
  end

  def show
    @post = Post.find_by_slug(params[:slug])
    @comment = Comment.new
  end
end
