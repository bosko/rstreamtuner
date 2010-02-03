require "tmpdir"

class XiphStream < StreamAPI
  stream :Xiph
  
  def initialize
    super('Xiph', 'dir.xiph.org')
    if config[:columns].nil?
      config[:columns] = []
      config[:columns] << {:header=>"Name", :attr=>:server_name, :width=>220}
      config[:columns] << {:header=>"Type", :attr=>:server_type, :width=>130}
      config[:columns] << {:header=>"Bitrate", :attr=>:bitrate, :width=>130}
      config[:columns] << {:header=>"Channels", :attr=>:channels, :width=>130}
      config[:columns] << {:header=>"Sample rate", :attr=>:samplerate, :width=>130}
      config[:columns] << {:header=>"Genres", :attr=>:all_genres, :width=>130}
      config[:columns] << {:header=>"Current song", :attr=>:current_song, :width=>175}
    end
    save_config
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

    @stations[:all]
  end

  def search!(criteria)
    return @stations[:search][criteria] if @stations[:search][criteria] and @stations[:search][criteria].length > 0

    @stations[:search][criteria] = @stations[:all].find_all do |st|
      st[:server_name].include? criteria or st[:genre].find { |genre| genre.include? criteria }
    end
    save_cache
    @stations[:search][criteria]
  end

  def pls_file(search_criteria, index)
    active_stations = []
    if search_criteria.nil?
      active_stations = @stations[:all]
    else
      active_stations = @stations[:search][search_criteria]
    end

    fpath = File.join(Dir.tmpdir, "xiph.pls")
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
