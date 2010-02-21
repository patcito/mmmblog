class Admin::DashboardController < Admin::BaseController
  layout 'dashboard'
  include OpenIdAuthentication

  def show
    @posts = Post.all(:order => 'created_at desc', :limit => 5)
    @comments = Comment.all(:order => 'created_at desc', :limit => 10)
  end
end
