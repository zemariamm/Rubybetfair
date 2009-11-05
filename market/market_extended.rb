require 'rubygems'
# require File.join(File.dirname(__FILE__)) + '/../includes.rb'

# reopen base classes to add utilities methods
class MarketDriver
  def getAllActiveMarkets(options={})
    #markets = self.getAllMarkets(options)
    #return markets.find_all { |md| md.tplay == true }
    getAllMarketsWhere(options) do |md|
      md.tplay == true
    end
  end

  def getAllMarketsWhere(options={},&b)
    markets = self.getAllMarkets(options)
    markets.find_all { |md| b.call(md) }
  end

  def search_by_game_name(name,options={})
    self.getAllMarketsWhere(options) do |md|
      md.game_name.casecmp(name) == 0
    end
  end

  def search_active_by_game_name(name,options={})
    self.getAllMarketsWhere(options) do |md|
      (md.game_name.casecmp(name) == 0) && (md.tplay == true) 
    end

  end
end

class MarketData
  def game_name
    ar = self.menu_path.split("\\")
    return ar[ar.length - 1]
  end
end

class Market
  def game_name
    ar = self.menuPath.split("\\")
    return ar[ar.length - 1]
  end
end
