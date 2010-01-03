class Station
  attr_accessor :id, :name, :url, :now_playing, :genres, :listeners

  def initialize
    @genres = Array.new
  end
end

