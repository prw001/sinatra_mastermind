require 'sinatra'
require 'sinatra/reloader'
require_relative 'GameTools.rb'

set :sessions, true

use Rack::Session::Pool

module Tools
	extend GameTools
end

title = 'MASTERMIND'


class Game
	include Tools

	def create_rows()
		rows = []
		12.times do 
			rows << [false, false, false, false]
		end
		return rows
	end

	attr_accessor :hints
	attr_reader :game_over
	attr_reader :rows
	attr_reader :turns_left
	attr_reader :secret_code
	attr_reader :colors

	def initialize
		@rows = create_rows
		@hints = create_rows
		@secret_code = Tools::generate_code
		@turns_left = 12
		@colors = ['R', 'O', 'Y', 'G', 'B', 'V']
		@game_over = false
	end

	def code_guessed?(guess)
		if guess == @secret_code
			@game_over = true
		end
	end

	def add_hints(guess)
		current_hints = Tools::generate_hints(guess, @secret_code, @colors)
		@hints[(turns_left-1)] = current_hints
		code_guessed?(guess)
	end

	def add_guess(guess)
		@rows[turns_left-1] = guess
		add_hints(guess)
		@turns_left -= 1
		if @turns_left == 0
			@game_over = true
		end
	end
end

get '/' do 
	erb :home, layout: :index, :locals => {:title => title}
end

get '/newgame' do 
	session[:game] = Game.new
	last_guess  = ''
	erb :play, layout: :index, 
		:locals => {:title => title, :game => session[:game]}
end

get '/guess' do 
	last_guess = []

	params.keys.each do |key|
		last_guess << params[key].downcase
	end

	unless last_guess.length == 0
		session[:game].add_guess(last_guess)
	end

	if session[:game].turns_left == 0 || session[:game].game_over
		redirect '/gameover'
	end

	erb :play, layout: :index, :locals =>{:title => title, :game => session[:game]}
end

get '/gameover' do 
	#stuff
end