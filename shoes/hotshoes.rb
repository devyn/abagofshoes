# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# Grabs the Shoes mailing list feed from gmane.org and displays it in a Shoes app.
# Click on a topic to see the email's body and any replies to it. Click on the text
# of an email and a webbrowser will open with a link to the topic on gmane
#
# Status:
# -------
# Working, but some features are missing and the RSS feed on gmane.org is limited to 21 items, haven't
# found a way around that yet

require 'rexml/document'
require 'open-uri'

Shoes.app do
  background "#201D1D"
  title "Hotshoes - Hot Shoes News", :stroke => white
  @doc = REXML::Document.new open("http://rss.gmane.org/messages/complete/gmane.comp.lib.shoes").read
  stack do
    @messages = []
    @doc.elements.each("rdf:RDF/item") do |item|
      @messages << {:title => item.elements["title"].text.gsub(/^Re\:\s/, ""),
                    :date => item.elements["dc:date"].text.gsub("T", " "),
                    :creator => item.elements["dc:creator"].text,
                    :description => item.elements["description"].text,
                    :link => item.elements["link"].text}
    end
    
    groups = Hash.new { |h,k| h[k] = [] }
    @messages.each do |msg|
      groups[msg[:title]] << msg
    end
    groups.each do |title, group|
      groups[title] = group.sort_by { |msg| msg[:date] }
    end
    @groups = (groups.values.sort_by { |msgs| msgs.first[:date] }).reverse
    
    @groups.each do |item|
      cur = stack(:margin_left => 15, :margin_right => 30, :margin_top => 15) do
        background black
        stack do
          background "#464646".."#000000"
          flow do
            para item[0][:date], :stroke => orange
            para item[0][:creator], :stroke => red
          end
          para item[0][:title], :stroke => white
        end
        opened = false
        click do
          if !opened
            opened = true
            cur.after do
              item.length.times do |count|
                stack(:margin_left => 15, :margin_right => 15, :margin_top => 15) do
                  background white
                  stack(:margin_left => 15, :margin_right => 15, :margin_top => 15) do
                    para item[count][:description]
                    click do
                      visit(item[count][:link])
                    end
                  end
                end
              end
            end
          else
            # I'll have to figure out how to hide the posts again
          end
        end
      end
    end
  end
end