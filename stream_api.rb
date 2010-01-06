require 'net/http'
require 'uri'
require 'nokogiri'

class StreamAPI
  attr_accessor :name, :url, :stations

  @@streams = Hash.new

  def self.stream(name)
    @@streams[name.to_s] = self
  end

  def self.streams
    @@streams
  end
  
  def initialize(name, url, chunk_size, fetch_limit)
    @config = Hash.new
    @name = name || "Invalid stream"
    @url = url
    @config[:chunk_size] = chunk_size
    @config[:fetch_limit] = fetch_limit
    @stations = Array.new
  end

  def clear_stations
    @stations.clear
  end

  def chunk_size
    @config[:chunk_size]
  end

  def chunk_size=(size)
    @config[:chunk_size] = size
  end
  
  def fetch_limit
    @config[:fetch_limit]
  end

  def fetch_limit=(limit)
    @config[:fetch_limit]
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
