$KCODE ='u'
require 'rubygems'
require 'jcode'
require File.join(File.dirname(__FILE__)) + '/../includes.rb'

betfair_driver = CommonBetfair.new
user = User.new(betfair_driver, {:username => 'root', :password => '*****'})
user.login

market = MarketDriver.new(betfair_driver)

vec = market.getAllActiveMarkets
names = vec.collect { |md| md.game_name + "#" + md.market_name }
puts names
