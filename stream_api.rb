require 'net/http'
require 'uri'
require 'nokogiri'
require 'rst_config'

class StreamAPI
  include RstConfig
  
  attr_accessor :name, :url

  @@streams = Hash.new

  def self.stream(name)
    @@streams[name.to_s] = self
  end

  def self.streams
    @@streams
  end
  
  def initialize(name, url)
    @name = name || "Invalid stream"
    @url = url
    cfg_file_name("#{@name}_config.yml")

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
  
  def pls_file(search_criteria, index)
    ''
  end
  
  def columns
    config[:columns]
  end

  def cache_file
    File.join(config_dir, "#{name}_cache.yml")
  end
  
  def column_width(idx, width)
    return unless config[:columns].is_a? Array
    config[:columns][idx][:width] = width
    save_config
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
