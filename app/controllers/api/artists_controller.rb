class Api::ArtistsController < ApplicationController
  before_action :set_artist, only: [:show, :update, :destroy]

  # GET /artists
  def index
    all_artists = $redis.get("all_artists")

    if all_artists.nil?
      all_artists = Artist.all.to_json
      $redis.set("all_artists", all_artists)
      $redis.expire("all_artists", 1800) # Expire in 30 minutes
    end
    @artists = all_artists
    render json: @artists
  end

  # GET /artists/1
  def show
    render json: @artist
  end

  # POST /artists
  def create
    @artist = Artist.new(artist_params)

    if @artist.save
      render json: @artist, status: :created, location: @artist
    else
      render json: @artist.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /artists/1
  def update
    if @artist.update(artist_params)
      render json: @artist
    else
      render json: @artist.errors, status: :unprocessable_entity
    end
  end

  # DELETE /artists/1
  def destroy
    @artist.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artist
      @artist = Artist.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def artist_params
      params.require(:artist).permit(:name, :years_active, :origin)
    end
end
