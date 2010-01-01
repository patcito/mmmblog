class CommentsController < ApplicationController
  include ApplicationHelper
  include OpenIdAuthentication

  before_filter :find_post, :except => [:new]

  def index
    if params[:post_id]
      @post = Post.find(params[:post_id])
      @comments = Comment.find_all_by_post_id(@post.id)
    else
      @comments = Comment.all
    end
  end

  def create
    @comment = Comment.new(session[:comment] || params[:comment])
    if params[:comment]
      session[:comment] = params[:comment]
    end
    if session[:comment] && session[:comment][:author] && session[:comment][:author].index('.')
      post_with_openid(session[:comment])
    else
      post_without_openid(params[:comment])
    end
  end
  protected

  def find_post
    @post = Post.find_by_permalink(*[:year, :month, :day, :slug].collect {|x| params[x] })
  end

  def post_without_openid(comment)
    @comment = Comment.new(comment)
    @comment.post_id = Post.find_by_slug(params[:slug]).id
    @comment.blank_openid_fields
    if @comment.body && (@comment.body.include?('://') || @comment.body.include?('.com'))
      failed_login
    else
      successful_login(@comment)
    end
  end

  def post_with_openid(comment)
          authenticate_with_open_id(comment[:author],
                    :required => [:nickname,
                    :email,
                    'http://axschema.org/contact/email',
                    'http://axschema.org/namePerson/first']
      ) do |result, identity_url, registration|
      if result.status.to_s == "successful"
        @comment = Comment.new(comment)
        @comment.post_id = Post.find_by_slug(params[:slug]).id
        @comment.author_url   = identity_url
        @comment.author       = (registration["fullname"] || registration["nickname"] || @comment.author_url).to_s
        @comment.author_email = (registration["email"] || @comment.author_url).to_s
        @comment.openid_error = ""
        successful_login(@comment)
      else
        failed_login result.message
      end
    end
  end

  def successful_login(comment)
    if comment.save
      session[:comment] = nil
      ##FIXME couldn't get :anchor=> to work
      redirect_to post_slug_path(comment.post)+"##{comment.id}"
    else
      failed_login
    end
  end

  def failed_login(message=nil)
    session[:comment] = nil
    redirect_to post_slug_path(Post.find_by_slug(params[:slug]))+"#new_comment"
  end
end

