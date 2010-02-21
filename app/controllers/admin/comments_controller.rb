class Admin::CommentsController < Admin::BaseController
  layout 'dashboard'
  include OpenIdAuthentication

  def show
    @posts = Post.all(:limit => 5)
    @comments = Comment.all(:limit => 10)
  end

  def edit
    @comment = Comment.find(params[:id])
    @post = @comment.post
  end

  def update
    @comment = Comment.find(params[:id])
    @comment.update_attributes(params[:comment])
    redirect_to :back
  end

  def index
    if params[:post_id]
      @comments = Comment.find_all_by_post_id(params[:post_id], :order => 'created_at desc')
    else
      @comments = Comment.all(:order => 'created_at desc')
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    if params[:post_id]
      redirect_to admin_post_comments_path(@comment.post)
    else
      redirect_to admin_comments_path
    end
  end
end
