require 'sinatra'
require 'sinatra/reloader'
require 'nokogiri'
require 'json'
require 'pry'
require 'csv'
require './game.rb'
require 'httparty'

url_list = ['http://odds.bestbetting.com/football/england/premier-league/','http://odds.bestbetting.com/football/germany/fu%C3%9Fball-bundesliga/','http://odds.bestbetting.com/football/spain/primera-divisi%C3%B3n/','http://odds.bestbetting.com/football/france/le-championnat/','http://odds.bestbetting.com/football/italy/serie-a/','http://odds.bestbetting.com/football/scotland/scottish-premiership/']

games_array = []

# requesting the page
url_list.each do |url|
  page = HTTParty.get(url)

  # making the http response into a nokogiri object
  parse_page = Nokogiri::HTML(page)

  # array of odds and names and checks
  teams_array = []
  odds_array = []


  # making the odds array from the html 
  parse_page.css(".row0, .row1").css(".selectionBestOdd").map do |a|
    # text odds will be needed to compute expectancies later on
    odds = a.text.gsub(/[()]/, "").strip
    # push each into the array
    odds_array.push(odds)
  end


  # making the competitors array from the html
  parse_page.css(".row0, .row1").css(".firstColumn").css("a").map do |a|
    title = a.text.split(" v ")
    teams_array.push(title[0]).push("draw").push(title[1])
  end

  # The interesting bit, it loops through every third element and does the calculation
  # RELIES HEAVILY ON THE FACT THAT TEAM ARRAY MATCHES ODDS ARRAY!!

  (0..odds_array.length-1).step(3) do |i|
    current_game = Game.new(odds_array[i],odds_array[i+1],odds_array[i+2],teams_array[i],teams_array[i+2])
    if current_game.success?
      current_game.set_potential
      if current_game.get_potential > 0
        games_array.push(current_game)
      end
    end
  end
end

big_list = ""

if games_array.length >0
  #sorting array
  games_array.sort_by! { |a|
    a.get_potential
  }
  
  games_array.reverse.each do |a|
    big_list += a.bets_breakdown
  end
end

if big_list.length <3
  big_list = "Empty, sorry"
end

get '/' do
  erb :index, :locals => {:bets => big_list}
end
