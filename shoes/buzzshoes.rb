# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# I wrote this for the 2008 Ruby Advent Calendar (http://advent2008.hackruby.com).
# There are some great Ruby articles on there, so go take a look!
#
# Description:
# ------------
# Grabs the most popular topics as talked about on Twitter by using the Tweetag.com API and
# then uses the YouTube API to find videos of these topics which you can then play from within
# the application.

Shoes.setup do
  # this tells Shoes to download and install a ruby gem inside Shoes' own
  # copy of rubygems
  gem "ruby-json"
end

require "json"

Shoes.app(:title => "BuzzShoes", :width => 640, :height => 500) do
  # here we define a few RGB colors to use in the app, there are already
  # dozens of them defined, take a look in the Shoes manual for a listing
  # of all the pre-defined colors
  @dark_purple = rgb(68, 0, 128)
  @purple = rgb(138, 43, 226)
  @grey = rgb(80, 80, 80)
  @light_grey = rgb(230, 230, 230)

  # this sets the background of the window, which is a flow, so it lays out
  # everything from left to right
  background gradient(black, @grey)

  # this returns an array with hashes of all the current twitter buzz words, updated every few minutes
  @buzzwords = JSON.parse(open("http://api.tweetag.com/tagcloud/").read)

  stack do
    flow do
      # this sets the background of the flow
      background gradient(@purple, @dark_purple)

      # title is one of the many different text labels you can use in Shoes
      # to display text in your apps. title uses a really big font size, while
      # para uses a good standart font size. Take a look in the Shoes manual
      # for more, it's under "Elements" > "TextBlock"
      title "Current buzz", :stroke => white
    end

    flow do
      background gradient(@grey, @light_grey)

      #this gives the flow a border
      border black, :strokewidth => 1

      # hack for Shoes on Linux: you could use flow(:height => 30) to define a height for this flow,
      # but then this flow overlaps the scrollbar so we will use an empty string here to give the
      # flow the preferred height
      para " "
    end

    stack do
      @buzzwords.each do |word|
        # show only words with more than 60 tweets
        if word["weight"] >= 60 and word["name"] != "all"
          # tagline is another one of those text labels Shoes provides
          tagline word["name"], :stroke => white, :margin_top => 10

          flow do
            videos = JSON.parse(open("http://gdata.youtube.com/feeds/api/videos?q=#{word["name"]}&alt=json&max-results=4").read)
            if videos["feed"]["entry"]
              videos["feed"]["entry"].each do |video|
                thumbnail_url = video['media$group']['media$thumbnail'][0]['url']
                @pic = image thumbnail_url, :margin_left => 20
                video_id = /http\:\/\/.*\/(.*)\/[0-9]\.jpg/.match(thumbnail_url)[1]

                # if the user clicks on an image open a new window with the YouTube video
                @pic.click do
                  window(:width => 500, :height => 400) do
                    background black
                    # find out the .flv file URL to the YouTube video
                    page = open("http://www.youtube.com/watch?v=#{video_id}").read
                    t = /, "t": "([^"]+)"/.match(page)[1]
                    url = "http://www.youtube.com/get_video?video_id=#{video_id}&t=#{t}"

                    # make a video player with the link to the YouTube video by using the video function
                    stack(:margin => 5) do
                      @vid = video url
                    end

                    # adding some controls for the video in HTML link style
                    para "controls: ",
                      link("play")  { @vid.play }, ", ",
                      link("pause") { @vid.pause }, ", ",
                      link("stop")  { @vid.stop }, :stroke => white

                    # when the window is fully loaded, start playing the video
                    start do
                      @vid.play
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
