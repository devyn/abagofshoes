# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# A chatlog viewer and log2html converter for aMSN and Mercury.
#
# Status:
# -------
# Not working, in development

require 'cgi'

class Sanitizer
  def self.amsn2html(path_to_file)
    open(path_to_file + ".html", "w") do |file|
      file.puts '<html>
      <head>
      <title>Chatlog</title>
      <META http-equiv="Content-Type" content="text/html; charset=UTF8">
      </head>
      <body>'
      open(path_to_file).each_line do |line|
        if line.include?("LRED")
          if line.include?("LTIME")
            if match = /\[(.+) \|\"LTIME([0-9]{10}) (.+)\]/.match(line)
              file.printf '<font color="red">%s</font><br>', "#{match[1]} #{Time.at(match[2].to_i).strftime("%d.%m.%Y - %H:%M:%S")} #{match[3]}"
            end
          else
            if match = /\[(.+)\]/.match(line)
              file.printf '<font color="red">%s</font><br>', "#{match[1]}"
            end
          end
        elsif line.include?("LGRA")
          if match = /\[\|\"LTIME([0-9]{10}) \] \|\"LITA(.+) \:\|\"LC([0-9a-zA-Z]{6}) (.+$)/.match(line)
            file.printf '<p><span style="background: #%s; color: white;">%s: %s</span><br>', match[3], Time.at(match[1].to_i).strftime("%d.%m.%Y - %H:%M:%S"), match[2]
            file.puts "#{CGI.escapeHTML(match[4])}<br>"
          elsif match = /\[([0-9]{2}\:[0-9]{2}\:[0-9]{2})\] \|\"LITA(.+) \:\|\"LC([0-9a-zA-Z]{6}) (.+$)/.match(line)
            file.printf '<p><span style="background: #%s; color: white;">%s: %s</span><br>', match[3], match[1], match[2]
            file.puts "#{CGI.escapeHTML(match[4])}<br>"
          end
        else
          file.puts CGI.escapeHTML(line) + "<br>"
        end
      end
      file.puts '</body></html>'
    end
  end
end

Shoes.app do
  Sanitizer::amsn2html(ask_open_file)
end