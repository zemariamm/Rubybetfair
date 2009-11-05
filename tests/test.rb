require 'rubygems'
gem "soap4r"
require 'soap/wsdlDriver'
require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'
require File.join(File.dirname(__FILE__)) + '/../base/user.rb'
require File.join(File.dirname(__FILE__)) + '/../market/market.rb'
require File.join(File.dirname(__FILE__)) + '/../market/market_utils.rb'

require File.join(File.dirname(__FILE__)) + '/../bets/bet.rb'

betfair_driver = CommonBetfair.new

user = User.new(betfair_driver,{:username => 'root', :password => '*******'})
# market = MarketDriver.new(betfair_driver)

user.login
puts user.logged_in?

bet = BetDriver.new(betfair_driver)
response = bet.getBetHistory
puts response.inspect


=begin
response = market.getAllMarkets
resp = response[0]
mid = resp.market_id

info = market.getMarketInfo({:marketId => mid})
puts "Delay:"
puts info.result.marketLite.delay
=end
=begin
response = market.getAllMarkets
# response.each_with_index do |resp, counter|
resp = response[0]
counter = 0
  
  # mid = response[0].market_id
mid = resp.market_id
puts "print #{counter}"
response2 = market.getMarketPricesCompressed({:marketId => mid})

obj = MarketPrice.fromString( response2.result.marketPrices)
puts obj.inspect
=end
=begin
  File.open("tests_prices/test" + counter.to_s + ".txt","w") do |fich|
    fich.print response2.result.marketPrices
  end
=end

# response = market.getInPlayMarkets
# response = market.getMarket(:marketId => 97383)
# puts response.inspect

user.logout
# user.keepAlive
# user.logout
#puts user.logged_in?

