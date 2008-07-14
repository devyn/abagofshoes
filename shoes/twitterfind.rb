# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# Search for Twitter messages by using summize.com
#
# Status:
# -------
# Working, but crashes often, threading doesn't work so it's deactivated,
# a few features are missing, and text is sometimes too big for the box
# it's being displayed in

require "rexml/document"
require "open-uri"
require 'cgi'

Shoes.app(:title => "Twitterfind", :width => 545) do
  @content = nil
  
  background "#363636"
  
  # Had to put this into a function or Shoes would crash. Also, the function
  # has to be inside the Shoes.app() {} block or otherwise, it doesn't work
  #
  # Fetches search results from summize.com as an Atom XML file,
  # parses the XML and displays an image and the Twitter message
  # for every entry.
  #
  # Without threading this makes the GUI really
  # unresponsive, but with threading enabled it displays message after
  # message and you don't have to wait at all, so hopefully threading will work
  # in a future version
  def getTwitters(searchTerm)
    # manual html encoding of whitespaces until I figure out why Shoes doesn't like Ruby CGI
    searchTerm = CGI::escape(searchTerm)
    
    # grabbing the search results for the given searchTerm from summize as a REXML document
    doc = REXML::Document.new open("http://summize.com/search.atom?lang=en&rpp=100&q=#{searchTerm}").read
    
    # this part swaps the current @content stack with the search result
    @content.clear {
      doc.elements.each("feed/entry") do |element|
        stack(:width => 500, :height => 80) do
          fill "#282828".."#141414", :angle => 180
          rect 0, 0, 500, 80, 5
          flow(:margin_left => 5, :margin_top => 5) do
            flow(:width => 50) do
              #clicking on avatar => visit the person's twitter profile in a webbrowser
              click do
                visit(element.elements['author'].elements['uri'].text)
              end
              
              element.each_element_with_attribute('rel', 'image', 1) do |pic|
                begin
                  image pic.attributes['href'] # downloads and displays avatar
                rescue
                  # just do nothing, this is to catch 404 errors
                end
              end
            end
            flow(:width => 440) do
              # clicking on message => visit the message on twitter in a webbrowser
              click do
                element.each_element_with_attribute('rel', 'alternate', 1) do |profile|
                  visit(profile.attributes['href'])
                end
              end
              
              inscription getFormattedTime(element.elements["published"].text), :stroke => orange
              para element.elements["title"].text, :stroke => white
            end
          end
        end
      end
    }
  end
  
  def getFormattedTime(timeString)
    match = /([0-9]{4}-[0-9]{2}-[0-9]{2})T([0-9]{2}:[0-9]{2}:[0-9]{2})Z/.match(timeString)
    return "#{match[1]} #{match[2]}"
  end
  
  # this is where the "main" app starts, displays an editbox for entering a searchterm
  # and a button to send the search off to the net
  stack do
    background "#000000", :height => 60
    flow :margin => 20 do
      @searchBox = edit_line
      button "Search" do
        @content.clear # clearing outside of the thread seems to work better than inside
        # Threading crashes the app too often, so it's deactivated for now
        #Thread.start do
          getTwitters(@searchBox.text)
        #end
      end
    end
  end
  # this is where the search results are displayed by the getTwitters() function
  @content = stack(:margin_left => 15) {para "Enter one or more searchwords and press the button", :stroke => white}
end