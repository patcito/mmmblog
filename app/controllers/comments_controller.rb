class CommentsController < ApplicationController
  include ApplicationHelper
  include OpenIdAuthentication

  OPEN_ID_ERRORS = {
    :missing  => "Sorry, the OpenID server couldn't be found",
    :canceled => "OpenID verification was canceled",
    :failed   => "Sorry, the OpenID verification failed" }

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
    @comment = Comment.new(session[:pending_comment] || params[:comment])
    @post = Post.find_by_slug(params[:slug])
    @comment.post_id = @post.id
    session[:pending_comment] = nil

    unless @comment.requires_openid_authentication?
      @comment.blank_openid_fields
    else
      session[:pending_comment] = params[:comment]
      return if authenticate_with_open_id(@comment.author, :optional => [:nickname, :fullname, :email]) do |result, identity_url, registration|
        if result.status == :successful
          @comment.post = @post

          @comment.author_url   = identity_url
          @comment.author       = (registration["fullname"] || registration["nickname"] || @comment.author_url).to_s
          @comment.author_email = (registration["email"] || @comment.author_url).to_s

          @comment.openid_error = ""
          session[:pending_comment] = nil
        else
          @comment.openid_error = OPEN_ID_ERRORS[ result.status ]
        end
      end
    end

    if session[:pending_comment].nil? && @comment.save
      ##FIXME couldn't get :anchor=> to work
      redirect_to post_slug_path(@comment.post)+"##{@comment.id}"
    else
      redirect_to post_slug_path(@post)+"#new_comment"
    end
  end

  protected

  def find_post
    @post = Post.find_by_permalink(*[:year, :month, :day, :slug].collect {|x| params[x] })
  end
end
