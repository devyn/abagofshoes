# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information

# Description:
# ------------
# Easily download YouTube videos
#
# Status:
# -------
# Working, but some features (like auto naming of files by getting the
# title from YouTube) are missing

require 'open-uri'
require 'net/http'

Shoes.app(:title => "TubularShoes", :width => 590, :height => 130, :resizable => false) do
  background black
  
  @newprogress = 0.0
  
  # helper functions
  
  # overwriting puts because it obviously doesn't work in a GUI, but is so nice to use
  def puts(text)
    @status_message.clear {
      para text, :stroke => white
    }
  end
  
  # get the file URL of a youtoube video
  def get_file(page)
    video_id = page.split("=")[1]
    puts "finding url"
    url = nil
    page = open("http://www.youtube.com/watch?v=#{video_id}").read
    t = /, "t": "([^"]+)"/.match(page)[1]
    url = "http://www.youtube.com/get_video?video_id=#{video_id}&t=#{t}"
    return url
  end
  
  # function to download stuff while providing status updates and error handling
  def download(url, as)
    puts "downloading..."
    Net::HTTP.start(url.host, url.port) do |http|
      http.request_get(url.request_uri) do |r|
        if r.header['Location']
          puts " => #{r.header['Location']}"
          download(URI(r.header['Location']), as)
        else
          File.open(as, 'wb') do |f|
            len = 0
            open_retries = 0
            read_retries = 0
            bytecount = 0
            begin
              r.value
              begin
                http.read_timeout = 5
                r.read_body do |chunk|
                  f.write(chunk)
                  len += chunk.length
                  @newprogress = (len * 1.0) / r.content_length
                end
              rescue Timeout::Error
                if read_retries < 4
                  read_retries += 1
                  puts "#{Time.now} - Encountered a timeout, retry number #{read_retries} of 4 retries"
                else
                  puts"#{Time.now} - Encountered a timeout while trying to download #{url}"
                end
              end
              puts "done"
            rescue Net::HTTPServerException
              if open_retries < 4
                open_retries += 1
                puts "#{Time.now} - Error while downloading, retry number #{open_retries} in 3 seconds..."
                sleep 3
                retry
              else
                puts "#{Time.now} - Encountered a #{$!} error while trying to download #{url}"
              end
            end
          end
        end
      end
    end
  end
  
  # main shoes app
  
  stack do
    stack do
      background "#666363".."#000000"
      
      flow(:margin_top => 10) do
        para "YouTube URL:", :stroke => white
        button("Paste") { @searchbox.text = clipboard } # Apple/Control + V doesn't work
        @searchbox = edit_line "http://youtube.com/watch?v=YqQISNKWZSA", :width => 300
        @search_button = button("Download") {
          file_url= get_file(@searchbox.text)
          filename = @searchbox.text.split("=")[1] + ".flv"
          Thread.start do
            download(URI.parse(file_url), filename)
            @newprogress = 0.0
          end
        }
      end
    end
    stack(:margin_top => 10) do
      flow do
        para "Progress: ", :stroke => white
        @status_bar = progress(:width => 500)
      end
      @status_message = stack do
        para "Ready to download...", :stroke => white
      end
    end
  end
  every(1) do
    @status_bar.fraction = @newprogress
  end
end
