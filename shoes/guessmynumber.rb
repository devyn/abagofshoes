# Copyright (C) 2008 Christoph Budzinski
#
# Licensed under the MIT license, see LICENSE.txt for more information
#
# Description:
# ------------
# A silly little "Guess a number from 1 to 100" game
#
# Why even do such a thing?
# -------------------------
# Guess a number was the first thing I ever wrote, when I was seven years
# old. I wrote it on my trusty one-line-display kids laptop-thingy in Basic :)
# So the short answer is: Nostalgia
#
# Status:
# -------
# Works, but Shoes has issues with flows at the moment, so the "New Game"
# button doesn't appear at the right position

class GuessGame
  attr_reader :guesses
  def initialize
    @guesses = 0
    @theNumber = rand(99)+1
  end
  
  def guess(number)
    @guesses += 1
    
    if number < @theNumber
      return -1
    elsif number == @theNumber
      return 0
    elsif number > @theNumber
      return 1
    end
  end
end

Shoes.app(:title => "Guess my Number", :height=> 100, :width => 490, :resizable => false) do
  background "#666363".."#000000"
  
  @game = GuessGame.new
  
  stack(:margin_top => 10, :margin_left => 10) do
    flow do
      flow do
        @editfield = edit_line
        @guess_button = button("Guess") do
          match = /[0-9]+/.match(@editfield.text)
          @editfield.text = ""
          if match
            guessed = match[0].to_i
            case @game.guess(guessed)
            when -1
              @message.replace("Nope, sorry. My number is bigger than #{guessed}!")
            when 0
              @message.replace("Awww, you won! Took you only #{@game.guesses} guesses. Thanks for playing!")
              @newgame_button_slot.clear do
                button("New Game") do
                  @game = GuessGame.new
                  @message.replace("Try to guess my number! It's between 1 and 100")
                  @newgame_button_slot.clear
                end
              end
            when 1
              @message.replace("Nah, my number isn't as big as #{guessed}!")
            end
          else
            @message.replace("Huh? That's not a number.")
          end
        end
      end
      @newgame_button_slot = flow {}
    end
    
    @message = para("Try to guess my number! It's between 1 and 100", :stroke => orange)
  end
end