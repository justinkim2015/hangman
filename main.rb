require 'colorize'

class Game
  attr_accessor :secret_word, :guess_word

  def initialize
    @secret_word = generate_word.chomp
    @secret_word_array = @secret_word.split('')
    @guess_word_array = Array.new(@secret_word.length, '_')
    @guess_word = ''
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

  def ask_letter
    puts 'Input a letter!'.bold
    letter = gets.chomp
    if letter.length == 1 && letter.downcase.match(/[a-z]/)
      letter
    else
      puts 'INVALID INPUT, PLEASE INPUT A-Z'.colorize(:red)
      ask_letter
    end
  end

  def match_letter
    guess_letter = ask_letter
    @secret_word_array.each.with_index do |letter, index|
      if letter == guess_letter
        @guess_word_array[index] = letter
        @guess_word = @guess_word_array.join
      end
    end
  end
end

class Board
  def initialize
    @guessed_letters = []
    @guesses_left = 10
  end

  def generate_board
    puts "You have #{@guesses_left} guesses left!".bold
    puts @guessed_letters
  end
end

game = Game.new
board = Board.new

puts game.secret_word
game.match_letter
puts game.guess_word
board.generate_board
