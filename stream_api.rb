require 'net/http'
require 'uri'
require 'nokogiri'

class StreamAPI
  attr_accessor :name, :url

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

    load_config
    @config = Hash.new if @config.nil?
    @config[:chunk_size] = chunk_size if @config[:chunk_size].nil?
    @config[:fetch_limit] = fetch_limit if @config[:fetch_limit].nil?

    load_cache
    if @stations.nil?
      @stations = Hash.new
      @stations[:all] = Array.new
      @stations[:search] = Hash.new
    end
    
  end

  def clear_stations
    @stations[:all].clear
  end

  def all_stations
    @stations[:all]
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

  def search_terms
    @stations[:search].keys
  end

  def clear_search(term)
    @stations[:search][term] = Array.new
  end

  def remove_search(term)
    @stations[:search].delete(term)
  end
  
  def pls_file(index)
    ''
  end
  
  def columns
    @config[:columns]
  end

  def config_file
    File.join(RstConfig.config_dir, "#{name}_config.yml")
  end

  def cache_file
    File.join(RstConfig.config_dir, "#{name}_cache.yml")
  end
  
  def column_width(idx, width)
    return unless @config[:columns].is_a? Array
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

  def load_cache
    @stations = YAML::load_file(cache_file) if File.exist? cache_file
  end

  def save_cache
    File.open(cache_file, 'w') do |f|
      f.write @stations.to_yaml
    end
  end
end
