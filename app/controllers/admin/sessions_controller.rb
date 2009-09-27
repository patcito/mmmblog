class Admin::SessionsController < ApplicationController
#   layout 'login'
  include OpenIdAuthentication

  def show
    if params[:openid_url]
      create
    else
      redirect_to :action => 'new'
    end
  end

  def new
  end

  def create
    return successful_login if allow_login_bypass? && params[:bypass_login]
    authenticate_with_open_id(params[:openid_url],
                    :required => [:nickname,
                    :email,
                    'http://axschema.org/contact/email',
                    'http://axschema.org/namePerson/first']
      ) do |result, identity_url, registration|
      if result.successful?
        if identity_url =~ %r{//www.google.com}
          identity_url = "http://google_id_#{registration["http://axschema.org/contact/email"][0]}"
        end
        cookies[:firstname] = registration["http://axschema.org/namePerson/first"][0]
        if AppConfig.author["open_id"].include?(identity_url)
          return successful_login
        else
          flash.now[:error] = "You are not authorized"
        end
      else
        flash.now[:error] = result.message
      end
      render :action => 'new'
    end
  end

  def destroy
    session[:logged_in] = false
    redirect_to('/')
  end

protected

  def successful_login
    session[:logged_in] = true
    redirect_to(admin_dashboard_path)
  end

  def allow_login_bypass?
    ["development", "test"].include?(RAILS_ENV)
  end
  helper_method :allow_login_bypass?
end
