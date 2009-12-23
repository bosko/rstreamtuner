class Station
  attr_accessor :id, :name, :url, :now_playing, :genres, :listeners

  def initialize
    @genres = Array.new
  end

  def tune_in
    "http://yp.shoutcast.com/sbin/tunein-station.pls?#{id}"
  end
end

