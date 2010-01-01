require 'net/http'
require 'uri'
require 'nokogiri'

class StreamAPI
  attr_accessor :name, :url, :chunk_size, :fetch_limit, :stations

  @@streams = Hash.new

  def self.stream(name)
    @@streams[name] = self
  end

  def self.streams
    @@streams
  end
  
  def initialize(name, url, chunk_size, fetch_limit)
    @name = name || "Invalid stream"
    @url = url
    @chunk_size = chunk_size
    @fetch_limit = fetch_limit
    @stations = Hash.new
  end

  def fetch!
  end

  def search!(criteria)
  end
end
