require 'error/error.rb'

class Api::UsersController < Api::BaseController
  # skip_before_action :verify_authenticity_token
  before_action :authenticate, only: [:sign_out]
  include ErrorHandling

  def sign_up
    user = User.where(email: params[:email]).first
    raise Error::Internal::UserExists       unless user.blank?
    raise Error::Internal::PasswordTooShort if params[:password].to_s.length <  Devise.password_length.begin

    @user = User.new(user_params)
    if @user.save
      render json: @user.as_json(only: [:email, :authentication_token]), status: :created
    else
      head(:unprocessable_entity)
    end
  end

  def sign_in
    user = User.where(email: params[:email]).first

    if user&.valid_password?(params[:password])
      render json: user.as_json(only: [:email, :authentication_token]), status: :created
    else
      head(:unauthorized)
    end
  end

  def sign_out
    @current_user&.authentication_token = nil
    if @current_user&.save
      head(:ok)
    else
      head(:unauthorized)
    end
  end
  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end