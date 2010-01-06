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
    load_config
    if @config.nil?
      @config = Hash.new
    end
    
    @name = name || "Invalid stream"
    @url = url
    @stations = Array.new
    @config[:chunk_size] = chunk_size
    @config[:fetch_limit] = fetch_limit
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

  def config_file
  end
  
  def column_width(idx, width)
    return unless @config[:columns].is_a? Array
    puts "Setting column #{idx} width to #{width}"
    @config[:columns][idx][:width] = width
    save_config
  end

  def load_config
    @config = YAML::load_file(config_file) if File.exist? config_file
  end

  def save_config
    File.open(config_file, 'w') do |f|
      f.write @config.to_yaml
    end
  end
end
