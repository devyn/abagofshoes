# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# Displays Arch Linux package updates with a description about what the
# package is for and the changelog of the new version by scanning other websites
# for information
#
# Status:
# -------
# In development

require 'rexml/document'

Shoes.app(:width => 500, :height => 500) do
  background black
  
  @updates = []
  @doc = REXML::Document.new open("http://archlinux.org/feeds/packages/").read
  @doc.elements.each("rss/channel/item") do |item|
    data = item.elements["title"].text.split(" ")
    @updates << {:title => data[0], :version => data[1], :arch => data[2], :description => item.elements["description"].text}
  end

  stack do
    stack do
      background black

      title "Arch Linux updates", :stroke => white
    end

    @i686 = stack(:margin_bottom => 10) do
      stack do
        background blueviolet..darkslateblue
        tagline "i686", :stroke => red
      end

    end

    @x86_64 = stack do
      stack do
        background blueviolet..darkslateblue
        tagline "x86_64", :stroke => red
      end

    end

    @updates.each do |item|
      if item[:arch] == "i686"
        @i686.append do
          stack do
            background "222".."000"
            flow do
              caption item[:title], :stroke => lime
              caption item[:version], :stroke => orange
            end
            para item[:description], :stroke => white
          end
        end
      else
        @x86_64.append do
          stack do
            background "222".."000"
            flow do
              caption item[:title], :stroke => lime
              caption item[:version], :stroke => orange
            end
            para item[:description], :stroke => white
          end
        end
      end
    end
  end
end
