require 'rubygems'
THIS_DIR = File.expand_path(File.dirname(__FILE__))
require File.join(File.dirname(__FILE__)) + '/../includes.rb'
Dir.chdir(THIS_DIR)
puts THIS_DIR
require 'activerecord'
require 'drb'





ActiveRecord::Base.establish_connection(
                                        :adapter => "mysql",
                                        :host => "localhost",
                                        :username => "root",
                                        :database => "betfair")

# FDX falta guardar os Time.now
class DBUtils

  attr_accessor :market_id, :hrunners , :bestbet

  def initialize
    self.hrunners = Hash.new
    DRb.start_service
    self.bestbet = DRbObject.new(nil,"druby://:1234")
  end

  def keep_walking
    loop do
      val = self.bestbet.queue.pop
      puts "added #{val.inspect}"
      add_market_price_compressed(val)
    end
  end

  def add_market(md)

    market = DBMarket.new

    market.bsp_market = md.bspMarket
    market.country_iso3 = md.countryISO3
    market.discount = md.discountAllowed
    market.eventHierarchy = md.eventHierarchy.join(", ")
    market.eventTypeId = md.eventTypeId
    market.interval = md.interval
    market.last_refresh = md.lastRefresh
    market.licenseId = md.licenceId
    market.market_base_rate = md.marketBaseRate
    market.market_description = md.marketDescription
    market.market_display_time = md.marketDisplayTime
    market.marketId = md.marketId
    market.market_status = md.marketStatus
    market.market_suspend_time = md.marketSuspendTime
    market.market_time = md.marketTime
    market.market_type = md.marketType
    market.market_type_variant = md.marketTypeVariant
    market.max_unit_value = md.maxUnitValue
    market.menu_path = md.menuPath
    market.min_unit_value = md.minUnitValue
    market.name = md.name
    market.number_of_winners = md.numberOfWinners
    market.parentEventId = md.parentEventId
    market.runners_may_be_added = md.runnersMayBeAdded
    market.timezone = md.timezone
    market.unit = md.unit
    market.save!
    
    # make cache of market_id
    self.market_id = market[:id]

    

    md.runners.each do |runner|
      run = DBRunner.new
      run.name = runner.name
      run.asianLineId = runner.asianLineId
      run.handicap = runner.handicap
      run.selectionId = runner.selectionId
      run.dbmarket = market
      run.save!
      # make cache of runner id
      self.hrunners[run.selectionId] = run[:id]
    end
  end

  
  def add_market_price_compressed(md)
    t = Time.now
    market_price = DBMarketPrice.new
    # get our DB market id, not the one from the API
    market_price.market_id = self.market_id

    market_price.marketId = md.marketId
    currency = md.currency
    market_price.market_status = md.marketStatusEnum
    market_price.inplay_delay = md.inPlayDelay
    market_price.number_winners = md.numberWinners
    market_price.market_info = md.marketInformation
    market_price.discount = md.discountAllowed
    market_price.market_base_rate = md.marketBaseRate
    market_price.refresh = md.refreshRate
    market_price.bsp = md.bsp

    market_price.save!
    md.runnerInfo.each do |runner|
      run = DBRunnerExtra.new
      # get the ID from the cache
      run[:runner_id] = self.hrunners[runner.selectionId]
      run[:selection_id] = runner.selectionId
      run[:order_index] = runner.orderIndex
      run[:total_amount_matched] = runner.totalAmountMatched
      run[:last_price_matched] = runner.lastPriceMatched
      run[:handicap] = runner.handicap
      run[:reduction_factor] = runner.reductionFactor
      run[:vacant] = runner.vacant
      run[:far_price] = runner.farSPPrice
      run[:near_price] = runner.nearSPPrice
      run[:actual_price] = runner.actualSPPrice
      run.save!
      
      runner.odds.each do |odd|
        b = DBBet.new
        b.tipo = odd.type
        b.amountAvailable = odd.amountAvailable
        b.price = odd.price
        b.time_betfair = t
        b[:market_price_id] = market_price[:id]
        b[:runner_extra_id] = run[:id]
        #b.dbmarket_price = market_price
        b.save!
      end
    end
  end

  # module_function :add_market_price_compressed, :add_market
end



class DBMarket < ActiveRecord::Base
  set_table_name("markets")

  has_many :dbrunners, :class_name => 'DBRunner'
  has_many :dbmarket_prices, :class_name => 'DBMarketPrice'
end  
  
class DBRunner < ActiveRecord::Base
  set_table_name("runners")
  
  has_many :dbrunner_extras, :class_name => 'DBRunnerExtra'
  has_one :dbmarket, :class_name => 'DBMarket'
end



class DBMarketPrice < ActiveRecord::Base
  set_table_name('market_prices')
  belongs_to :dbmarket, :class_name => 'DBMarket'
  has_many :dbbets, :class_name => 'DBBet'
  has_many :dbrunner_extras, :through => :dbbets, :class_name => 'DBRunnerExtra'
end


class DBRunnerExtra < ActiveRecord::Base
  set_table_name('runner_extras')
  has_one :dbrunner, :class_name => 'DBRunner'
  # belongs_to :dbmarket_price


end
class DBBet < ActiveRecord::Base
  set_table_name('bets')
  
  belongs_to :dbmarket_price, :class_name => 'DBMarketPrice'
  belongs_to :dbrunner_extra, :class_name => 'DBRunnerExtra'
end

dbcontroller = DBUtils.new
dbcontroller.keep_walking

=begin
m = DBMarket.new
m.name = 'soccer'
m.save!

r = DBRunner.new
r.name = 'benfica'
r.dbmarket = m
r.save!

0.upto(10) do |n|
  mp = DBMarketPrice.new
  mp.save!

  0.upto(2) do |x|
    r2 = DBRunnerExtra.new(:selectionId => 0)
    r2.save!

    b = DBBet.new
    b.tipo = 1
    b.price = x
    b.dbmarket_price = mp
    b.dbrunner_extra = r2
    b.save!
  end
end

=end
