require 'error/error.rb'

class Api::UsersController < Api::BaseController
  # skip_before_action :verify_authenticity_token
  before_action :authenticate, only: [:sign_out, :favourites]
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

  def favourites
    hash     = {}
    song_ids = @current_user.favourites.uniq!
    songs    = $redis.get("songs")

    unkown_id_list = if songs
      known_songs = JSON.load songs

      song_ids.select do |song_id|
        song_id_str = song_id.to_s
        if known_songs[song_id_str]
          hash[song_id_str] = known_songs[song_id_str]
          next
        end
        true
      end
    else
      song_ids
    end

    unkown_id_list.each do |song_id|
      song   = Song.find(song_id)
      artist = Artist.find(song.artist_id)

      artist_details = {
        name:         artist.name,
        years_active: artist.years_active,
        origin:       artist.origin
      }

      song_details = {
        title:  song.title,
        genre:  song.genre,
        artist: artist_details
      }

      hash[song_id] = song_details
    end

    json_hash = hash.to_json
    $redis.set("songs", json_hash)
    $redis.expire("songs", 1800) # Expire in 30 minutes

    render json: { songs: hash.values }
  end

  private

  def user_params
    params.permit(:email, :password, :password_confirmation)
  end
end