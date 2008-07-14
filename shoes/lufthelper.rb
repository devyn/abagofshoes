# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# A helper utility for developing AIR(+HTML/CSS/JavaScript) applications
#
# Why the freakish name?
# ----------------------
# Luft is the german word for air, I didn't want to get into trouble for calling it AIRhelper ;)
#
# Status:
# -------
# Working, but it is in a very early stage. The only thing it does for now is generating
# an application descriptor file for your AIR application, which is useful only if you don't use
# an IDE for developing AIR apps. Only the most basic options for AIR can be set, I'll add more options
# over time. If you don't want to set an optional option, just leave it blank.

Shoes.setup do
  gem 'builder'
end

require 'builder'

class Airhelper
  def self.generate_descriptor_file(options)
    myxmldata = ""
    x = Builder::XmlMarkup.new(:target => myxmldata, :indent => 4)
    x.instruct!
    x.application("xmlns" => "http://ns.adobe.com/air/application/1.0") do
      x.id(options[:id])
      x.name(options[:name])
      x.version(options[:version])
      x.filename(options[:filename])
      x.description(options[:description])
      x.copyright(options[:copyright])
      x.initialWindow do
        x.content(options[:initial_window_content])
        x.title(options[:initial_window_title])
        x.visible(options[:initial_window_visible])
        x.width(options[:initial_window_width]) if options[:initial_window_width] != ""
        x.height(options[:initial_window_height])if options[:initial_window_height] != ""
      end
    end
    return myxmldata
  end
end

Shoes.app(:title => "LUFThelper", :width => 500, :height => 670) do
  background "#303030".."#000000"
  
  stack(:margin_left => 20) do
    title "General app settings", :stroke => purple
    
    flow do
      tagline "id: ", :stroke => orange
      @id = edit_line("com.mydomain.myapp")
    end
    flow do
      tagline "name: ", :stroke => orange
      @name = edit_line("MyAppName")
    end
    flow do
      tagline "version: ", :stroke => orange
      @version = edit_line("1.0")
    end
    flow do
      tagline "filename: ", :stroke => orange
      @filename = edit_line("MyAppName")
    end
    flow do
      tagline "description: ", :stroke => orange
      @description = edit_line("This app does this and that.")
    end
    flow do
      tagline "copyright: ", :stroke => orange
      @copyright = edit_line("Copyright (C)#{Time.now.year} YourCompany/Name")
    end
    
    title "Initial window settings", :stroke => purple
    
    flow do
      tagline "content: ", :stroke => orange
      @content = edit_line("index.html")
    end
    flow do
      tagline "title: ", :stroke => orange
      @title = edit_line("MyApp version 1.0")
    end
    flow do
      tagline "visible: ", :stroke => orange
      @visible = edit_line("true")
    end
    flow do
      tagline "width: ", :stroke => orange
      @width = edit_line("400")
      para " (optional)", :stroke => yellow
    end
    flow do
      tagline "height: ", :stroke => orange
      @height = edit_line("300")
      para " (optional)", :stroke => yellow
    end
    
    button("Create") do
      xmldata = Airhelper.generate_descriptor_file({:id => @id.text,
                                                    :name => @name.text,
                                                    :version => @version.text,
                                                    :filename => @filename.text,
                                                    :description => @description.text,
                                                    :copyright => @copyright.text,
                                                    :initial_window_content => @content.text,
                                                    :initial_window_title => @title.text,
                                                    :initial_window_visible => @visible.text,
                                                    :initial_window_width => @width.text,
                                                    :initial_window_height => @height.text})
      save_as = ask_save_file
      open(save_as, "wb") do |file|
        file.puts xmldata
      end
    end
  end
end