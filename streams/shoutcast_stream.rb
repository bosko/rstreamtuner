class ShoutcastStream < StreamAPI
  stream :Shoutcast
  
  def initialize
    super('Shoutcast', 'www.shoutcast.com', 50, 100)
  end
  
  def fetch!
    fetched_cnt = 0
    http = Net::HTTP.new(url)
    
    begin
      ref = fetched_cnt * chunk_size + 1
      return unless ref < fetch_limit
      
      resp, data = http.get("/directory.jsp?startIndex=#{ref}&numresult=#{chunk_size}&ref=','#{ref}")
      
      value = Nokogiri::HTML.parse(data)
      box_element = value.css('div.boxcenterdir')

      grey_elements = box_element.css('div.dirGreyexpand')
      process_elements(grey_elements) unless grey_elements.nil?
      
      blue_elements = box_element.css('div.dirBlueexpand')
      process_elements(blue_elements) unless blue_elements.nil?
      fetched_cnt += 1
    end while resp.code.to_i == 200
  end

  def search!(criteria)
    fetched_cnt = 0
    http = Net::HTTP.new(url)

    begin
      ref = fetched_cnt * chunk_size + 1
      search_url = "/directory/searchKeyword.jsp?startIndex=#{ref}&numresult=#{chunk_size}&mode=listener&searchCrit=simple&s=#{criteria}"
      resp, data = http.get(search_url)
      value = Nokogiri::HTML.parse(data)
      greys = value.css('div.dirGreyexpand')
      process_elements(greys) unless greys.nil?
      
      blues = value.css('div.dirBlueexpand')
      process_elements(blues) unless blues.nil?
      fetched_cnt += 1
    end while resp.code == 200
  end

  private
  def process_elements(elements)
    return unless elements.is_a? Nokogiri::XML::NodeSet
    elements.each do |elem|
      begin
        station = Station.new
        station.id = elem.attributes['id'].value.match(/\d+/)[0]
        station.name = elem.css('a.dirStationCntexpand')[0].attributes['title'].value
        station.url = elem.css('a.dirStationCntexpand')[0].attributes['href'].value
        station.now_playing = elem.css('div.dirNowPlayingCntexpand')[0].attributes['title'].value
        elem.css('div.dirGenreDiv').css('a').each do |g|
          station.genres << g.text
        end
        station.listeners = elem.css('div.dirListenersDiv').css('span').map {|x| x.text}.join(' ')
        def station.file
          http = Net::HTTP.new('yp.shoutcast.com')
          resp, data = http.get("/sbin/tunein-station.pls?id=#{id}")
          fpath = "/tmp/sc_#{id}.pls"
          File.open(fpath, 'w') do |f|
            f.write data
          end
          fpath
        end
        
        stations << station
      rescue
      end
    end
  end
end
