module RstConfig
  # Allows accessing config variables from rst.yml like so:
  # RstConfig[:domain] => some-domain.com
  def self.[](key)
    unless @config
      @config = YAML.load(config_file) if File.exist?(config_file)
    end
    @config[key]
  end
  
  def self.[]=(key, value)
    @config[key.to_sym] = value
  end

  def self.save_config
    if @config
      File.open(config_file, 'w') do |f|
        f.write @config.to_yaml
      end
    end
  end
  
  def self.config_dir
    dir = File.join(ENV['HOME'], '.rstreamtuner')
    unless File.exist?(dir)
      FileUtils.mkdir_p(dir)
    end
    dir
  end

  def self.config_file
    File.read(File.join(config_dir, "rst.yml"))
  end
end
