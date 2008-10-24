# Menu for a bag of shoes
# Made by Devyn

Shoes.app do
    background "#888".."#000"
    title "a bag of shoes\n"
    Dir.entries(File.dirname(__FILE__)).each do |rbfile|
        next if rbfile == 'menu.rb'
        next if File.directory?(rbfile)
        image File.join(File.dirname(__FILE__), '..', 'res', 'bullet.png'), :width => 26, :height => 26
        para link(rbfile.sub(/\.rb$/, ""), :stroke => '#F60').click{load File.join(File.dirname(__FILE__), rbfile)}
        para "\n"
    end
end

