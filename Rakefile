require File.join(File.dirname(__FILE__)) + "/includes.rb"
=begin
require File.join(File.dirname(__FILE__)) + '/base/common.rb'
require File.join(File.dirname(__FILE__)) + '/base/user.rb'

require File.join(File.dirname(__FILE__)) + '/market/market.rb'
require File.join(File.dirname(__FILE__)) + '/events/event.rb'
require File.join(File.dirname(__FILE__)) + '/bets/bet.rb'
=end
=begin
 SHOES = "/Applications/installed/shoes/Shoes.app/Contents/MacOS/shoes "

THIS_DIR = File.expand_path(File.dirname(__FILE__))
namespace :apps do
  desc "Run GUI"
  task :gui do 
    system( SHOES + THIS_DIR + "/apps/gui.rb")
  end
end
=end

betfair_driver = CommonBetfair.new
user = User.new(betfair_driver, {:username => 'root', :password => '******'})
user.login

namespace :dev do

  namespace :bets do
    bet = BetDriver.new(betfair_driver)

    desc "get Bet history"
    task :getBetHistory do
      response = bet.getBetHistory
      response.each do |bet|
        puts bet.inspect
      end
    end

    desc "Place Bets"
    task :placeBets do
      response = bet.placeBets
      puts response.result.inspect


  end

  end

  namespace :events do
    
    event = EventDriver.new(betfair_driver)
    
    desc "Get Active Event Types"
    task :getActiveEventEventTypes do
      response = event.getActiveEventTypes
      puts response.inspect

    end

    desc "Get All Event Types"
    task :getAllEventTypes do
      response = event.getAllEventTypes
      response.each { |et| puts "#{et.name} #{et.id}" }
    end


end


  namespace :market do
    market = MarketDriver.new(betfair_driver)
    
    mid = nil
    desc "Load Market ID: 97383"
    task :loadMarket do
      mid = 97383
      # mid = 100613627
    end

    rid = nil
    # 563519
    desc "Load Runner/Selection ID: 563519"
    task :loadRunner do
      rid = 563519
    end

    desc "Retrieve all markets"
    task :allMarkets do
      response = market.getAllMarkets(:eventTypeIds => [2])
      puts response.inspect
    end
    
    desc "Retrieve In-Play Markets"
    task :inPlayMarkets do
      response = market.getInPlayMarkets
      puts response
    end

    desc "Retrieve Complete Market Prices Compressed"
    task :completeMarketPricesCompressed => :loadMarket do
      response = market.getCompleteMarketPricesCompressed({:marketId => mid})
      puts response.result
    end

    desc "Retrieve Market Prices Compressed"
    task :marketPricesCompressed => :loadMarket do
      marketprices = market.getMarketPricesCompressed({:marketId => mid})
      # marketprices = MarketPrice.fromString(response.result.marketPrices)
      puts marketprices.inspect
    end

    desc "Retrieve Market Info"
    task :marketInfo => :loadMarket do
      response = market.getMarketInfo({:marketId => mid})
      puts response.inspect
    end
    
    desc "Retrieve AvailableMarketDepth for selectionId"
    task :marketdepth => [:loadMarket,:loadRunner] do
      response = market.getDetailAvailableMarketDepth({:marketId => mid,
                                                        :selectionId => rid})
      puts response.inspect
    end

    desc "Retrieve Traded Volume for certain match and runner"
    task :tradedVolume => [:loadMarket,:loadRunner] do
      response = market.getMarketTradedVolume({:marketId => mid,
                                                :selectionId => rid})
      puts response.inspect
    end
  end


  
end

namespace :info do

  namespace :bets do
    desc "completed tasks:"
    task :done do
      puts "Completed Market tasks:"
      ar = ["getBetHistory"]
      ar.each { |method| puts "#{method} : Completed" }
    end

    desc "Todo tasks:"
    task :todo do
      
    end


  end

  namespace :events do
    desc "completed tasks:"
    task :done do
      puts "Completed Market tasks:"
      ar = ["getAllEventTypes","getActiveEventTypes"]
      ar.each { |method| puts "#{method} : Completed" }
    end

    desc "Todo tasks:"
    task :todo do
      ar = [ ["getBet", "need implement everything"],
             ["getBetLite" , "need implement everything"],
             ["getBetMatchesLite","need implement everything"],
             ["getCurrentBets","need implement everything"],
             ["getCurrentBetsLite","need implement everything"],
             ["placeBets","need implement everything"],
             ["cancelBets","need implement everything"],
             ["cancelBetsByMarket","need implement everything"],
             ["updateBets","need implement everything"] ]
      ar.each { |meth,str| puts "#{meth} : #{str}" }
    end

  end


  namespace :market do

    desc "completed tasks"
    task :done do
      puts "Completed Market tasks:"
      done = ["getAllMarkets","getMarketPricesCompressed","getInPlayMarkets","getMarket"]
      done << "getMarketInfo" << "getDetailAvailableMarketDepth" << "getMarketTradedVolume"
      done.each { |method| puts "#{method} : Completed" }
    end
    
    desc "todo Market Tasks:"
    task :todo do
      puts "todo Market tasks:"
      ar = [
            ["getMarketPrices","need implement everything"],
            ["getCompleteMarketPricesCompressed", "need implement everything"],
            ["getMarketProfitAndLoss","need implement everything"],
            ["getMarketTradedVolumeCompressed","need implement everything"]]

      ar.each { |meth,str| puts "#{meth} : #{str}" }
    end
  end
end


