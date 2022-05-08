require 'colorize'
require 'yaml'

# This module contains all text
module Text
  def line_break
    print "------------------------------\n"
  end

  def input_please_text
    line_break
    puts 'Input a letter or type "save"!'.bold
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

  def overwrite_text
    print "\n"
    puts 'That file exists, overwrite?(y/n)'.colorize(:red)
    print "\n"
  end

  def save_name_text
    print "\n"
    puts 'What would you like to name your save?'.bold
    print "\n"
  end

  def load_name_text
    print "\n"
    puts 'Which file would you like to load?(case sensitive)'.bold
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

# This module contains methods to save and load game
module SaveGame
  def serialize
    YAML.dump(self)
  end

  def self.deserialize(yaml)
    YAML.load(yaml)
  end

  def load_name
    load_name_text
    display_saves
    name = "#{gets.chomp}.txt"
    if !no_repeat?(name)
      name
    else
      puts 'INVALID FILE NAME'
      load_name
    end
  end

  def load_file(file_name)
    game_file = File.open("/home/justin/hangman/saves/#{file_name}", 'r')
    yaml = game_file.read
    YAML.load(yaml)
    SaveGame.deserialize(yaml)
  end

  def save_file(file_name)
    File.open("/home/justin/hangman/saves/#{file_name}", 'w') { |file| file.puts serialize }
  end

  def save_game
    save_file(save_name)
    print "\n"
    puts 'See you later!'.blink
  end

  def save_name
    save_name_text
    display_saves
    name = "#{gets.chomp}.txt"
    if no_repeat?(name)
      name
    elsif overwrite?
      name
    else
      save_name
    end
  end

  def no_repeat?(file)
    true unless current_saves.include?(file)
  end

  def current_saves
    Dir.entries('saves').select { |f| File.file? File.join('saves', f) }
  end

  def display_saves
    saves = current_saves
    puts saves
    print "\n"
  end

  def overwrite?
    overwrite_text
    answer = gets.downcase.chomp
    case answer
    when 'y'
      true
    when 'n'
      false
    else
      overwrite?
    end
  end

  def load_save
    puts 'Would you like to load a save? y/n'
    ans = gets.chomp
    case ans
    when 'y'
      load_file(load_name)
    when 'n'
      puts 'initializing...'
    else
      load_save
    end
  end
end

# This class contains game logic and error checking
class Game
  include Text
  include Board
  include SaveGame

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

  def no_match?(letter)
    true unless @secret_word_array.include?(letter)
  end

  def wrong_letters(letter)
    @wrong_letters.push(letter) if no_match?(letter)
  end

  def check_letter(guess_letter)
    @secret_word_array.each.with_index do |letter, index|
      if letter == guess_letter
        @guess_word_array[index] = letter
        @guess_word = @guess_word_array.join
      end
    end
  end

  def play_round(input)
    return if input.nil?

    guess_letter = input
    check_letter(guess_letter)
    wrong_letters(guess_letter)
    lose_life(guess_letter)
  end

  def ask_input
    input_please_text
    input = gets.chomp
    if valid_letter?(input)
      input
    elsif input == 'save'
      save_game
    else
      invalid_text
      ask_input
    end
  end

  def win?
    return unless @guess_word == @secret_word

    generate_board(@guess_word)
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
      generate_board(@guess_word)
      input = ask_input
      play_round(input)
      break if input.nil?
    end
  end
end

game = Game.new
game_data = game.load_save
game = if game_data.nil?
         Game.new
       else
         game_data
       end
game.play_game

