require 'rubygems'
# require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'
require File.join(File.dirname(__FILE__)) + '/market_utils.rb'
require File.join(File.dirname(__FILE__)) + '/market_lite.rb'
require File.join(File.dirname(__FILE__)) + '/available_market_depth.rb'
require File.join(File.dirname(__FILE__)) + '/traded_volume.rb'
=begin
Methods to implement:
- getAllMarkets
   - ready
   - return array:MarketData

- getMarketPricesCompressed
    - Ready, return MarketPrice

- getInPlayMarkets
   - ready
   - necessita de uma API paga

- getMarket
   - ready
   - returns: objecto Market

- getMarketInfo

- getMarketPrices

- getCompleteMarketPrices

- getDetailAvailableMarketDepth

- getMarketProfitAndLoss

- getMarketTradedVolume

- getMarketTradedVolumeCompressed

=end


class MarketDriver < BetfairContainer
  include BetfairHelpers
  @@dlocale = nil
  @@dasianLineId = nil
  @@deventTypesIds = []
  @@dcountries = []
  @@dfromDate = nil
  @@dtoDate = nil
  
  @@dcurrencyCode = nil
  @@dincludeCouponLinks = false


  def initialize(bfdriver)
    super(bfdriver)
  end
  
  
  def getMarket(options = {})
    check_required_vars(options,:marketId)
    packet = load_defaults(options, {:includeCouponLinks => @@dincludeCouponLinks,
                             :locale => @@dlocale })
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling getMarket with #{packet.inspect.to_s}"
      response = driver.getMarket(:request => packet)
      response
    end
    ans
    return Market.fromXml(ans.result.market)
  end

  def getMarketTradedVolume(options = {})
    $logger.info "getMarketTradedVolume not checking for asianLineId"
    check_required_vars(options,[:marketId,:selectionId])
    packet = load_defaults(options, {:currencyCode => @@dcurrencyCode,
                           :asianLineId => @@dasianLineId })
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling getMarketTradedVolume with #{packet.inspect}"
      driver.getMarketTradedVolume(:request => packet)
  end
    return TradedVolume.fromXml(ans.result)
  end



  def getDetailAvailableMarketDepth(options = {})
    $logger.info "getDetailAvailableMarketDepth not checking for asianLineId"
    check_required_vars(options,[:marketId,:selectionId])
    packet = load_defaults(options, {:currencyCode => @@dcurrencyCode,
                           :locale => @@dlocale,:asianLineId => @@dasianLineId })
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling getDetailAvailableMarketDepth with #{packet.inspect}"
      driver.getDetailAvailableMktDepth(:request => packet)
    end
    return AvailableMarketDepth.fromXml(ans.result.priceItems)
  end


  # returns markets that will be turned in-play the next 24-hour
  # need a subscription API account to test this
  def getInPlayMarkets(options = {})
    packet = load_defaults(options, {:locale => @@dlocale})
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      $logger.info "Calling getInPlayMarkets with #{packet.inspect.to_s}"
      packet = packet.merge(header)
      response = driver.getInPlayMarkets(:request => packet)
      response
    end
    vec = clean(marketData.split(":"))
    return vec.collect {|vline| MarketData.from_string(vline) }
  end

  # 97383  -> funciona
  # 20692870 -> funciona
  def getCompleteMarketPricesCompressed(options = {})
    check_required_vars(options,:marketId)
    packet = load_defaults(options, {:currencyCode => @@dcurrencyCode})
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      $logger.info "Calling getMarketPrices with #{packet.inspect.to_s}"
      packet = packet.merge(header)
      response = driver.getCompleteMarketPricesCompressed(:request => packet)
      response
    end
    ans
  end

  # 97383  -> funciona
  # 20692870 -> funciona
  def getMarketPricesCompressed(options = {})
    check_required_vars(options,:marketId)
    packet = load_defaults(options, {:currencyCode => @@dcurrencyCode})
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      $logger.info "Calling getMarketPrices with #{packet.inspect.to_s}"
      packet = packet.merge(header)
      response = driver.getMarketPricesCompressed(:request => packet)
      response
    end
    MarketPrice.fromString(ans.result.marketPrices)
    # ans
  end

  def getMarketInfo(options = {})
    check_required_vars(options,:marketId)
    packet = options
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      $logger.info "Calling getMarketInfo for market: #{options[:marketId]}"
      packet = packet.merge(header)
      driver.getMarketInfo(:request => packet)
    end
    ans
    return MarketLite.fromXml(ans.result.marketLite)
  end

  def getAllMarkets(options = {})
    marketData = ""
    packet = load_defaults(options, {
                             :locale => @@dlocale,
                             :eventTypeIds => @@deventTypesIds,
                             :countries => @@dcountries,
                             :fromDate => @@dfromDate,
                             :toDate => @@dtoDate })
    ans = execute_remote(:exchange_uk) do |driver|
      header =  get_api_req_header
      $logger.info "Calling getAllMarkets with #{packet.inspect.to_s}"
      packet = packet.merge(header)
      response = driver.getAllMarkets(:request => packet)
      marketData = response.result.marketData
      $logger.debug "Response: #{marketData.inspect}"
      response
    end
    vec = clean(marketData.split(":"))
    v = vec.collect {|vline| MarketData.from_string(vline) }
    return v.compact
  end

  def clean(vec)
    vec.delete_if { |str| str.empty? }
    vec
  end

end


class Market 
  include BetfairHelpers
  @@vars = [
            {:bspMarket => :boolean},
            :countryISO3,
            {:couponLinks => :array},
            {:discountAllowed => :boolean},
            {:eventHierarchy => :array},
            {:eventTypeId => :integer},
            {:interval => :integer},
            {:lastRefresh => :integer},
            {:licenceId => :integer},
            {:marketBaseRate => :double},
            :marketDescription,
            {:marketDescriptionHasDate => :boolean},
            {:marketDisplayTime => :datetime},
            {:marketId => :integer},
            {:marketStatus => :string},
            {:marketSuspendTime => :datetime},
            {:marketTime => :datetime},
            {:marketType => :string},
            {:marketTypeVariant => :string},
            {:maxUnitValue => :integer},
            :menuPath,
            {:minUnitValue => :integer},
            {:name => :string},
            {:numberOfWinners => :integer},
            {:parentEventId => :integer},
            {:runners => :array},
            {:runnersMayBeAdded => :boolean},
            :timezone,{:unit=>:integer} ]
  
  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end
  
  def Market.fromXml(market_xml)
    $logger.error "ha 3 campos que estao a ser mal calculados na classe Market: marketSuspendTime, marketTime, marketDisplayTime"
    obj = Market.new
    @@vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = market_xml.send(varname)
      if (varname == :runners)
        var_value = Runner.load_from_array(val_from_xml.runner)
        $logger.debug "Loaded runners: #{var_value.inspect}"
      elsif (varname == :eventHierarchy)
        var_value = val_from_xml.eventId.collect do |elem|
          elem.to_i
        end
        $logger.debug "Loaded eventHierarchy: #{var_value.inspect}"
      else
        var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml) 
      end        
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
    end
    obj
  end
end
