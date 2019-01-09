require 'error/error.rb'

class Api::ArtistsController < ApplicationController
  before_action :set_artist, only: [:show, :update, :destroy]
  include ErrorHandling

  # GET /artists
  def index
    all_artists = $redis.get("all_artists")

    if all_artists.nil?
      all_artists = Artist.all.to_json
      $redis.set("all_artists", all_artists)
      $redis.expire("all_artists", 1800) # Expire in 30 minutes
    end
    @artists = JSON.load all_artists

    respond_to do |format|
      format.json { render json: @artists }
      format.xml  { render xml: @artists.to_xml }
    end
  end

  # GET /artists/1
  def show
    respond_to do |format|
      format.json { render json: @artist }
      format.xml  { render xml: @artist.as_json.to_xml }
    end
  end

  # POST /artists
  def create
    if request.content_type == "application/xml"
      document = Nokogiri::XML(request.body.read)
      schema = Nokogiri::XML::Schema(File.read('/home/ira/Desktop/sleepy_cat_api/schema.xsd'))
      validation = schema.validate(document)

      if validation.empty?
        xml_params = Hash.from_xml(document.to_s)
        @artist = Artist.new(xml_params["artist"].symbolize_keys)
      else
        raise Error::Internal::InvalidXML
      end
    else
      @artist = Artist.new(artist_params)
    end

    if @artist.save
      respond_to do |format|
        format.json { render json: @artist, status: :created }
        format.xml  { render xml: @artist.as_json.to_xml, status: :created }
      end
    else
      respond_to do |format|
        format.json { render json: @artist.errors, status: :unprocessable_entity }
        format.xml  { render xml: @artist.errors.as_json.to_xml, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artists/1
  def update
    if @artist.update(artist_params)
      respond_to do |format|
        format.json { render json: @artist, status: :ok }
        format.xml  { render xml: @artist.as_json.to_xml, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: @artist.errors, status: :unprocessable_entity }
        format.xml  { render xml: @artist.errors.as_json.to_xml, status: :unprocessable_entity }
      end
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
