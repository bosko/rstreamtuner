class XiphStream < StreamAPI
  stream :Xiph
  
  def initialize
    super('Xiph', 'dir.xiph.org', 0, 0)
    if @config[:columns].nil?
      @config[:columns] = []
      @config[:columns] << {:header=>"Name", :attr=>:server_name, :width=>220}
      @config[:columns] << {:header=>"Type", :attr=>:server_type, :width=>130}
      @config[:columns] << {:header=>"Bitrate", :attr=>:bitrate, :width=>130}
      @config[:columns] << {:header=>"Channels", :attr=>:channels, :width=>130}
      @config[:columns] << {:header=>"Sample rate", :attr=>:samplerate, :width=>130}
      @config[:columns] << {:header=>"Genres", :attr=>:all_genres, :width=>130}
      @config[:columns] << {:header=>"Current song", :attr=>:current_song, :width=>175}
      save_config
    end
  end
  
  def fetch!
    return @stations[:all] if @stations[:all].length > 0

    fetched_cnt = 0
    http = Net::HTTP.new(url)
    resp, data = http.get("/yp.xml")
    if resp.code.to_i == 200
      doc = Nokogiri::XML(data)
      entries = doc.xpath('//directory/entry')
      entries.each do |entry|
        begin
          station = Hash.new
          entry.children.each do |child|
            if child.is_a? Nokogiri::XML::Element
              key = child.name.to_sym
              val = child.inner_text
              if child.name == 'genre'
                station[:all_genres] = val
                val = child.inner_text.split ' '
              end
              station[key] = val
            end
          end
          @stations[:all] << station
        rescue => e
          puts e.message
          puts "Error parsing #{entry}"
        end
      end
    end
    save_cache

    all_stations
  end

  def search!(criteria)
  end

  def pls_file(search_criteria, index)
    active_stations = []
    if search_criteria.nil?
      active_stations = @stations[:all]
    else
      active_stations = @stations[:search][search_criteria]
    end

    fpath = ''
    if Config::CONFIG['host_os'] =~ /mswin|mingw/
      # Windows version
      fpath = "c:/tmp/xiph.pls"
    else
      fpath = "/tmp/xiph.pls"
    end

    File.open(fpath, 'w') do |f|
      f.puts "[playlist]"
      f.puts "numberofentries=1"
      f.puts "File1=#{active_stations[index][:listen_url]}"
      f.puts "Title1=#{active_stations[index][:server_name]}"
      f.puts "Length1=-1"
    end
    return fpath
  end
  
end
