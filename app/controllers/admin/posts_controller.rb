class Admin::PostsController < Admin::BaseController
  layout 'dashboard'
  include OpenIdAuthentication

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    @post.author = cookies[:firstname]
    if @post.save
      redirect_to edit_admin_post_path(@post)
    else
      render :new
    end
  end

  def edit
    @post = Post.find(params[:id])
  end

  def update
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post])
    redirect_to edit_admin_post_path(@post)
  end

  def index
    @posts = Post.find(:all, :order => 'created_at desc')
  end
end
