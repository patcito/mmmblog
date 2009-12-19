class PostsController < ApplicationController
  def index
    @author = params[:author]
    @tag = params[:tag]
    @posts = Post.find_latest(:tag => @tag, :author => @author)

    respond_to do |format|
      format.html
      format.atom { render :layout => false }
    end
  end

  def show
    @post = Post.find_by_slug(params[:slug])
    @comments = Comment.find(:all, :order => 'created_at asc',
                             :conditions => {:post_id => @post.id})
    @comment = Comment.new
  end
end
