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
    @songs = JSON.load all_songs

    respond_to do |format|
      format.json { render json: @songs }
      format.xml  { render xml: @songs.to_xml }
    end
  end

  # GET /songs/1
  def show
    respond_to do |format|
      format.json { render json: @song }
      format.xml  { render xml: @song.as_json.to_xml }
    end
  end

  # POST /songs
  def create
    @song = Song.new(song_params)

    if @song.save
      respond_to do |format|
        format.json { render json: @song, status: :created }
        format.xml  { render xml: @song.as_json.to_xml, status: :created }
      end
    else
      respond_to do |format|
        format.json { render json: @song.errors, status: :unprocessable_entity }
        format.xml  { render xml: @song.errors.as_json.to_xml, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1
  def update
    if @song.update(song_params)
      respond_to do |format|
        format.json { render json: @song, status: :ok }
        format.xml  { render xml: @song.as_json.to_xml, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: @song.errors, status: :unprocessable_entity }
        format.xml  { render xml: @song.errors.as_json.to_xml, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1
  def destroy
    @song.destroy
  end

  def add_to_favourites
    @current_user.favourites << @song.id
    if @current_user.save
      respond_to do |format|
        format.json { render json: {}, status: :ok }
        format.xml  { head :ok }
      end
    else
      respond_to do |format|
        format.json { render json: @current_user.errors, status: :unprocessable_entity }
        format.xml  { render xml: @current_user.errors.as_json.to_xml, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def song_params
      params.require(:song).permit(:title, :artist_id, :genre)
    end
end
