require 'json'
require 'open-uri'

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :add_to_playlist]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @spotify_user = RSpotify::User.new(@user.credentials)
    @lastfm = Lastfm.new(ENV['lastfm_key'],ENV['lastfm_secret_key'])
    get_current_track
    get_spotify_version_of_track if @current_track
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def add_to_playlist
    @spotify_user = RSpotify::User.new(@user.credentials)
    playlist = @spotify_user.playlists.detect { |pl| pl.id == params[:playlist] }
    tracks = [ RSpotify::Track.find(params[:track]) ]
    playlist.add_tracks!(tracks)
    respond_to do |format|
      format.js
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user]
    end

    def get_current_track
      current_track = @lastfm.user.get_recent_tracks('paulgonz6').detect { |s| s["nowplaying"] == "true" }
      @current_track = @lastfm.track.get_info(:track => current_track["name"], :artist => current_track["artist"]["content"]).with_indifferent_access if current_track
    end

    def spotify_tracks_array
      @array = RSpotify::Track.search("#{@current_track[:name].gsub(/[^A-Za-z0-9 ]/, '')}", limit: 50)
    end

    def get_spotify_version_of_track
      spotify_tracks_array
      @spotify_track = smart_select || @array.first
    end

    def smart_select
      song = @current_track[:name].downcase
      artist = @current_track[:artist][:name].downcase
      album = @current_track[:album][:title].downcase
      @array.detect { |s| s.name.downcase == song && s.artists.first.name.downcase == artist && s.album.name.downcase == album }
    end

end
