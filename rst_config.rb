module RstConfig
  attr :config_file
  
  def self.included(c)
    def c.editable(*args)
      @@editable = args
    end
  end

  def config
    load_config unless @config
    @config
  end

  def cfg_file_name(file_name)
    @config_file = File.join(config_dir, file_name)
  end
  
  def load_config
    @config = YAML::load_file(config_file) if File.exist? config_file
    @config ||= {}
  end
  
  def save_config
    if @config
      File.open(config_file, 'w') do |f|
        f.write @config.to_yaml
      end
    end
  end
  
  def config_dir
    dir = File.join(ENV['HOME'], '.rstreamtuner')
    unless File.exist?(dir)
      FileUtils.mkdir_p(dir)
    end
    dir
  end

  def editable_settings
    @@editable ||= []
    es = Hash.new
    @config.each do |k, v|
      if @@editable.include? k
        es[k] = v
      end
    end
    es
  end
end
