# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# Sends a random word to Flickr and displays pictures that are tagged with
# this word. You then have to guess wich word was used to get these pictures.
#
# Every round you can win as much as 1000 points. For each false guess,
# 100 points are substracted from the amount of points that you can win
# in this round.
#
# There are two game modes, quick and long. The quick mode has 5 rounds,
# the long mode has 10.
#
# Status:
# -------
# Not working, in development

require 'rexml/document'
require 'open-uri'

class PictureGame
  attr_reader :score
  attr_reader :total_score
  attr_reader :round
  attr_reader :rounds
  attr_reader :guesses
  
  # rounds = how many rounds to play
  def initialize(rounds)
    @rounds = rounds
    
    # round information (gets reset every round)
    @score = 1000
    @guesses = 0
    @searchword = ""
    
    @total_score = 0
    @round = 0
    
    @words = %w(
                "cat
                dog
                beach
                sky
                sea
                ocean
                desert
                pyramid
                temple
                car
                motorbike
                bike
                lantern
                seaweed
                fish
                hamster
                computer
                game
                telephone
                headphones
                stereo
                purple
                red
                green
                blue
                orange
                yellow
                glass
                tree
                flower
                chair
                sofa
                wall
                house
                castle"
                )
  end
  
  # starts a new round, is also used for the first round
  # returns an Array with URLs to the pictures that were found as Strings
  def next_round
    if @round < @rounds
      
      # resetting the round information
      @score = 1000
      @guesses = 0
    
      @round += 1
    
      # getting a random searchword to use for retrieving a bunch of pictures
      @searchword = self.random_searchword
    
      # Important!!!: If you use this code to make a new application, you have to get your own Flickr API Key, you are not allowed to use this one, because each application needs it's own API key.
      # You can get a Flickr API key for free and instantly by logging in to Flickr with your Flickr account and visiting the site: http://www.flickr.com/services/api/keys/
      doc = REXML::Document.new open("http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=30358eb0314dedf2b990f925d6fcd2b4&media=photos&per_page=25&tags=#{@searchword}").read
    
      # building an array with pictures out of the informations from the XML file
      pictures = []
      doc.elements.each("rsp/photos/photo") do |photo|
        pictures << "http://farm#{photo.attributes["farm"]}.static.flickr.com/#{photo.attributes["server"]}/#{photo.attributes["id"]}_#{photo.attributes["secret"]}_t.jpg"
      end
    
      return pictures
    else
      return false # if the game is over
    end
  end
  
  def random_searchword
    return @words[rand(@words.length-1)]
  end
  
  def guess(word)
    if word == @searchword
      @total_score += @score
      return true
    else
      @score -= 200
      @guesses += 1
      return false
    end
  end
  
end

Shoes.app do
  background "#000000"
  
  @game = PictureGame.new(5)
  stack do
    flow do
      background "#666363"
    
      @textfield = edit_line
      @button = button("Guess") do
        if @game.guess(@textfield.text)
          # guess was right, start next round
          alert("That's right! Get ready for the next round.")
          if pictures = @game.next_round
            @pics.clear do
              pictures.each do |pic|
                image pic
              end
            end
          else
            # game is over, show total points and stuff
            alert("Game over! Thanks for playing!")
          end
        else
          alert("Nope, sorry. That's not the right word. Try again!")
        end
        @scoreinfo.replace("Score: #{@game.total_score} - Round: #{@game.round} / #{@game.rounds} - Guess: #{@game.guesses} / 5")
      end
      
      @scoreinfo = para "Score: #{@game.total_score} - Round: #{@game.round} / #{@game.rounds} - Guess: #{@game.guesses} / 5", :stroke => orange
    end
    
    @pics = flow do
      pictures = @game.next_round
      pictures.each do |pic|
        image pic
      end
    end
    
  end
  
end