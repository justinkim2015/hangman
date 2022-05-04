require 'colorize'

# This module contains all text
module Text
  def line_break
    print "---------------\n"
  end

  def input_please_text
    line_break
    puts 'Input a letter!'.bold
    line_break
  end

  def winner_text
    print "-----------\n".colorize(:green).blink
    puts '| WINNER! |'.colorize(:green).blink
    print "-----------\n".colorize(:green).blink
    print "\n"
  end

  def loser_text
    puts "LOSER! The answer was #{@secret_word}".colorize(:red).blink
    print "\n"
  end

  def invalid_text
    print "\n"
    puts 'INVALID INPUT, TRY AGAIN'.colorize(:red)
    print "\n"
  end
end

# This module contains methods to display game
module Board
  def generate_board(word)
    print "\n"
    puts "#{@guesses_left} lives left!".colorize(:red)
    print "\n"
    print "Incorrect Letters: #{@wrong_letters.join(', ')}\n".underline
    print "\n"
    print "#{space_word(word)}\n"
    print "\n"
  end

  def space_word(word)
    word.split('').join(' ')
  end
end

# This class contains game logic and error checking
class Game
  include Text
  include Board

  attr_accessor :secret_word, :guess_word

  def initialize
    @secret_word = generate_word.chomp
    @secret_word_array = @secret_word.split('')
    @guess_word_array = Array.new(@secret_word.length, '_')
    @guess_word = @guess_word_array.join(' ')
    @guesses_left = 10
    @wrong_letters = []
  end

  def generate_word
    dictionary = File.readlines('dictionary.txt')
    random_num = rand(9_999)
    if dictionary[random_num].length >= 5 && dictionary[random_num].length <= 12
      dictionary[random_num]
    else
      generate_word
    end
  end

  def valid_letter?(letter)
    true if letter.length == 1 &&
            letter.downcase.match(/[a-z]/) &&
            !@guess_word_array.include?(letter) &&
            !@wrong_letters.include?(letter)
  end

  def ask_letter
    input_please_text
    letter = gets.chomp
    if valid_letter?(letter)
      letter
    else
      invalid_text
      ask_letter
    end
  end

  def no_match?(letter)
    true unless @secret_word_array.include?(letter)
  end

  def wrong_letters(letter)
    @wrong_letters.push(letter) if no_match?(letter)
  end

  def play_round
    guess_letter = ask_letter
    @secret_word_array.each.with_index do |letter, index|
      if letter == guess_letter
        @guess_word_array[index] = letter
        @guess_word = @guess_word_array.join
      end
    end
    wrong_letters(guess_letter)
    lose_life(guess_letter)
  end

  def win?
    return unless @guess_word == @secret_word

    winner_text
    true
  end

  def lose?
    return unless @guesses_left.zero?

    loser_text
    true
  end

  def lose_life(guess)
    @guesses_left -= 1 if no_match?(guess)
  end

  def play_game
    until lose? || win?
      play_round
      generate_board(@guess_word)
    end
  end
end

game = Game.new
game.play_game
