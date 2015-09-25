module SpotifyTrack

  def self.grab(user)
    @spotify_user = RSpotify::User.new(user.credentials)
    @lastfm = Lastfm.new(ENV['lastfm_key'],ENV['lastfm_secret_key'])
    get_current_track
    get_spotify_version_of_track if @current_track
  end

  def self.get_current_track
    current_track = @lastfm.user.get_recent_tracks('paulgonz6').detect { |s| s["nowplaying"] == "true" }
    @current_track = @lastfm.track.get_info(:track => current_track["name"], :artist => current_track["artist"]["content"]).with_indifferent_access if current_track
  end

  def self.spotify_tracks_array
    @array = RSpotify::Track.search("#{@current_track[:name].gsub(/[^A-Za-z0-9 ]/, '')}", limit: 50)
  end

  def self.get_spotify_version_of_track
    spotify_tracks_array
    @spotify_track = smart_select || @array.first
  end

  def self.smart_select
    song = @current_track[:name].downcase
    artist = @current_track[:artist][:name].downcase
    album = @current_track[:album][:title].downcase if @current_track[:album]
    @array.detect { |s| s.name.downcase == song && s.artists.first.name.downcase == artist && (s.album.name.downcase == album if album) }
  end

end