require 'error/error.rb'

class Api::SongsController < Api::BaseController
  include ErrorHandling
  before_action :authenticate, only: [:add_to_favourites]
  before_action :set_song, only: [:show, :update, :destroy, :add_to_favourites]

  # GET /songs
  def index
    all_songs = $redis.get("all_songs")

    if all_songs.nil?
      all_songs = Song.all.to_json
      $redis.set("all_songs", all_songs)
      $redis.expire("all_songs", 1800) # Expire in 30 minutes
    end
    @songs = all_songs

    render json: @songs
  end

  # GET /songs/1
  def show
    render json: @song
  end

  # POST /songs
  def create
    @song = Song.new(song_params)

    if @song.save
      render json: @song, status: :created, location: @song
    else
      render json: @song.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /songs/1
  def update
    if @song.update(song_params)
      render json: @song
    else
      render json: @song.errors, status: :unprocessable_entity
    end
  end

  # DELETE /songs/1
  def destroy
    @song.destroy
  end

  def add_to_favourites
    @current_user.favourites << @song.id
    if @current_user.save
      render json: {}, status: :created
    else
      render json: @current_user.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def song_params
      params.require(:song).permit(:title, :atrist_id, :genre)
    end
end
