class Admin::DashboardController < Admin::BaseController
  layout 'dashboard'
  include OpenIdAuthentication

  def show
    @posts = Post.find(:all, :order => 'created_at desc', :limit => 5)
    @comments = Comment.find(:all, :order => 'created_at desc', :limit => 10)
  end
end
