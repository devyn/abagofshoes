# Copyright (C)2008 Devyn (http://github.com/devyn)
# Copyright (C)2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# A menu that Devyn made for all the apps in the Bag of Shoes, I just
# redesigned it so everything else is thanks to him and if you don't like the design
# it's all my fault ;)

Shoes.app(:title => "a Bag of Shoes - menu") do
  background "#555".."#333"
  
  stack do
  	stack do
  		background midnightblue..blue
	  	title "a Bag of Shoes", :stroke => white, :align => "center"
	  end
	  
	  stack(:margin_bottom => 20) do
	  	background dimgray..darkgray
	  	para " "
	  end
	  
		Dir.entries(File.dirname(__FILE__)).each do |rbfile|
			flow(:margin_left => 20) do
		    next if rbfile == 'menu.rb'
		    next if File.directory?(rbfile)
		    next if rbfile.include?("~")
		    image(25, 25) do
		    	nostroke
		    	fill black
		    	oval(0, 5, 20)
		    end
		    caption link(rbfile.sub(/\.rb$/, ""), :stroke => white).click{load File.join(File.dirname(__FILE__), rbfile)}
		  end
		end
	 end
end

