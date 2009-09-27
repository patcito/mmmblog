ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resource :session

    admin.resource :dashboard, :controller => 'dashboard'

    admin.resources :posts, :has_many => :comments
    admin.resources :comments
  end

  map.connect '/admin', :controller => 'admin/dashboard', :action => 'show'
  map.root :controller => 'posts', :action => 'index'
  map.resources :posts, :has_many => :comments

  map.new_author_slug_comment ':year/:month/:day/authors/:author/:slug/comments/new', :controller => 'comments', :action => 'new', :method => :get, :requirements => { :year => /\d+/ }

  map.post_author_slug_comments ':year/:month/:day/authors/:author/:slug/comments', :controller => 'comments', :action => 'create', :method => :post, :requirements => { :year => /\d+/ }

  map.post_slug_comments ':year/:month/:day/:slug/comments', :controller => 'comments', :action => 'create', :method => :post, :requirements => { :year => /\d+/ }

  map.slug_comments ':year/:month/:day/:slug/comments.:format', :controller => 'comments', :action => 'index', :requirements => { :year => /\d+/ }

  map.slug_comments_with_author ':year/:month/:day/authors/:author/:slug/comments.:format', :controller => 'comments', :action => 'index', :requirements => { :year => /\d+/ }

  map.slug_comments_with_author_tag ':year/:month/:day/authors/:author/:slug/:tag/comments.:format', :controller => 'comments', :action => 'index', :requirements => { :year => /\d+/ }

    map.all_comments '/comments.:format', :controller => 'comments', :action => 'index'
  map.all_comments_with_author '/authors/:author/comments.:format', :controller => 'comments', :action => 'index'
  map.all_comments_with_author_tag '/authors/:author/:tag/comments.:format', :controller => 'comments', :action => 'index'


  map.new_slug_comment ':year/:month/:day/:slug/comments/new', :controller => 'comments', :action => 'new', :requirements => { :year => /\d+/ }

  map.slug ':year/:month/:day/:slug', :controller => 'posts', :action => 'show', :requirements => { :year => /\d+/ }
  map.slug_with_author ':year/:month/:day/authors/:author/:slug', :controller => 'posts', :action => 'show', :requirements => { :year => /\d+/ }
  map.slug_with_tag ':year/:month/:day/:slug/:tag', :controller => 'posts', :action => 'show', :requirements => { :year => /\d+/ }
  map.slug_with_author_tag ':year/:month/:day/authors/:author/:slug/:tag', :controller => 'posts', :action => 'show', :requirements => { :year => /\d+/ }
  map.posts_with_author '/authors/:author', :controller => 'posts', :action => 'index'
  map.formatted_posts_with_author '/authors/:author.:format', :controller => 'posts', :action => 'index'
  map.posts_with_author_tag '/authors/:author/:tag', :controller => 'posts', :action => 'index'
  map.formatted_posts_with_author_tag '/authors/:author/:tag.:format', :controller => 'posts', :action => 'index'
  map.posts_with_tag ':tag', :controller => 'posts', :action => 'index'
  map.formatted_posts_with_tag ':tag.:format', :controller => 'posts', :action => 'index'
#   map.formatted_slug_comments ':year/:month/:day/:slug/comments.:format', :controller => 'comments', :action => 'index', :requirements => { :year => /\d+/ }
  map.connect '/', :controller => 'posts', :action => 'index'
end
