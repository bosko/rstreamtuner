require 'net/http'
require 'uri'
require 'nokogiri'

class StreamAPI
  attr_accessor :name, :url, :chunk_size, :fetch_limit, :stations

  @@streams = Hash.new

  def self.stream(name)
    @@streams[name.to_s] = self
  end

  def self.streams
    @@streams
  end
  
  def initialize(name, url, chunk_size, fetch_limit)
    @name = name || "Invalid stream"
    @url = url
    @chunk_size = chunk_size
    @fetch_limit = fetch_limit
    @stations = Array.new
  end

  def clear_stations
    @stations.clear
  end
  
  def fetch!
  end

  def search!(criteria)
  end

  def pls_file(index)
    ''
  end
  
  def columns
    []
  end
end
