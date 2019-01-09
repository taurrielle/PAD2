class Api::BaseController < ApplicationController
  def authenticate
    raise Error::Internal::InvalidAuthenticationToken unless authenticate_user
    authenticate_user
  end

  private

  def authenticate_user
    authenticate_with_http_token do |token, options|
      @current_user = User.find_by(authentication_token: token)
    end
  end
end