$KCODE ='u'
require 'rubygems'
require 'jcode'
require File.join(File.dirname(__FILE__)) + '/../includes.rb'

betfair_driver = CommonBetfair.new
user = User.new(betfair_driver, {:username => 'root', :password => '******'})
user.login

market = MarketDriver.new(betfair_driver)

# search_gamename = "Keothavong v Mirza"
# vec = market.search_by_game_name(search_gamename,{:eventTypeIds => [2]})
# vec = market.search_active_by_market_name(search_gamename,{})
vec = market.getAllActiveMarkets( {:eventTypeIds => [2]} )


# vec = vec.find_all{ |md|  md.event_date.day == Time.now.day }

# select only final game odds - "winner"
vec = vec.find_all {|md| md.market_name.casecmp("Match Odds") == 0 }

vec.each do |md|
  mid = md.market_id
  md = market.getMarket(:marketId => mid)
  puts "Jogo: #{md.game_name}"
  puts "Evento: #{md.name}"
  puts "Possibilidades:"
  md.runners.each do |runner|
    puts "#{runner.name} (selectionId: #{runner.selectionId} )"
    prices = market.getDetailAvailableMarketDepth({:marketId => mid, :selectionId => runner.selectionId})
    prices.priceItems.each do |ainfo|
      puts "Odds #{ainfo.odds} Available: #{ainfo.totalAvailableBackAmount}"
      # puts "totalAvailableBackAmount #{ainfo.totalAvailableBackAmount}"
      # puts "totalAvailableLayAmount #{ainfo.totalAvailableLayAmount}"
      # puts "totalBspBackAmount #{ainfo.totalBspBackAmount}"
      # puts "totalBspLayAmount #{ainfo.totalBspLayAmount}"
    end
  end
end  

