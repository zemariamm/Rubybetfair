require 'rubygems'
# require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'

class RexFunctions

  TILDE = 2.chr
  PIPE = 3.chr
  COMMA = 4.chr
  COLON = 5.chr
  SEMICOLON = 6.chr
  SUBS = {
    "\\~" => TILDE,
    "\\|" => PIPE,
    "\\," => COMMA,
    "\\:" => COLON,
    "\\;" => SEMICOLON,
  }
  SUBS.keys.each do |key|
    val = SUBS[key]
    SUBS[val] = key
  end

  attr_accessor :str
  
  def initialize(string)
    SUBS.keys.each { |key| string.gsub!(key,SUBS[key]) }
    self.str = string
  end
end

class MarketPrice
  include BetfairHelpers

  @@marketinfo = [
                  {:marketId => :integer},
                  :currency,
                  :marketStatusEnum,
                  {:inPlayDelay => :integer},
                  {:numberWinners => :integer},
                  :marketInformation,
                  {:discountAllowed => :boolean},
                  :marketBaseRate,
                  {:refreshRate => :integer},
                  {:removedRunnerInfo => :array},
                  {:bsp => :boolean} ]
  
  @@vars = [
            {:marketId => :integer},
            :currency,
            :marketStatusEnum,
            {:inPlayDelay => :integer},
            {:numberWinners => :integer},
            :marketInformation,
            {:discountAllowed => :boolean},
            :marketBaseRate,
            {:refreshRate => :integer},
            {:removedRunnerInfo => :array},
            {:bsp => :boolean},
            {:runnerInfo => :array} ]
            # {:backPrices => :array},
            # {:layPrices => :array} ]

  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end

  def MarketPrice.fromString(str)
    mk = MarketPrice.new
    str = RexFunctions.new(str).str
    marketPricesStrings = str.split(":")
    raise "Malformed String #{str}" if marketPricesStrings.size < 1
    $logger.info "Processing MarketPrices: #{str}"
    marketInfoStrings = marketPricesStrings[0].split("~")
    $logger.info "marketInfoStrings: #{marketInfoStrings}"
    $logger.warn "Need to process Removed Runner Info, see Market#fromXml"
    @@marketinfo.each_with_index do |symvar, index|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = marketInfoStrings[index]
      $logger.debug "Create field #{varname} value: #{val_from_xml}"
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      mk.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
    end
    mk.runnerInfo = Array.new
    marketPricesStrings[1...marketPricesStrings.size].each do |line|
      player_lay_back = line.split("|")
      player = player_lay_back[0]
      player_details = player.split("~")
      runner = RunnerInformation.fromArray(player_details)
      $logger.info "Created Runner #{runner}"
      runner_odds = Array.new
      player_lay_back[1...player_lay_back.size].each do |odd|
        odd_details = odd.split("~")
        n = 0
        while (n < odd_details.size)
          upperbound = n + 4
          runner_odds << Odd.fromArray(odd_details[n ... upperbound])
          n = n + 4
        end
      end
      runner.odds = runner_odds
      mk.runnerInfo << runner
    end
    mk
  end

end

class Odd
  def Odd.fromArray(ar)
    raise "Odd not valid #{ar}" if ar.size != 4
    type = ar[2]
    if (type.casecmp("l") == 0 || type.casecmp("lay") == 0)
      $logger.info "creating Back Price with #{ar}"
      return BackPrice.new(ar[0].to_f,ar[1].to_f,ar[2],ar[3].to_i)
    else
      $logger.info "creating Lay Price with #{ar}"
      return LayPrice.new(ar[0].to_f,ar[1].to_f,ar[2],ar[3].to_i)
    end
  end
end


class BackPrice
  include BetfairHelpers
  @@vars = [
            {:price => :double}, #odds,
            {:amountAvailable => :double},
            :type,
            {:depth => :integer} ]
  
  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end

  def initialize(_price,_amount,_type,_depth)
    self.price = _price
    self.amountAvailable = _amount
    self.type = _type
    self.depth = _depth
  end
end

class LayPrice
  include BetfairHelpers
  @@vars = [
            {:price => :double}, #odds,
            {:amountAvailable => :double},
            :type,
            {:depth => :integer} ]
  
  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end              

  def initialize(_price,_amount,_type,_depth)
    self.price = _price
    self.amountAvailable = _amount
    self.type = _type
    self.depth = _depth
  end
end
  
class RunnerInformation
  include BetfairHelpers

  @@vars = [
            {:selectionId => :integer},
            {:orderIndex => :integer},
            {:totalAmountMatched => :double},
            {:lastPriceMatched => :double},
            {:handicap => :double},
            {:reductionFactor => :double},
            {:vacant => :boolean},
            {:farSPPrice => :double},
            {:nearSPPrice => :double},
            {:actualSPPrice => :double}]

  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end        
  attr_accessor :odds

  def RunnerInformation.fromArray(ar)
    $logger.debug "Creating Runner Information"
    obj = RunnerInformation.new
     @@vars.each_with_index do |symvar, index|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = ar[index]
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
      $logger.debug "Create field #{varname} value: #{var_value}"
    end
    obj
  end
  
end
=begin
class RemovedRunnerInformation
  include BetfairHelpers
  @@vars = [
            :selectionName,
            {:removedData => :datetime},
            :adjustmentFactor ]

  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end  
end
=end

class Runner
  include BetfairHelpers
  @@vars = [ {:asianLineId => :integer },
             {:handicap => :double },
             :name,
             {:selectionId => :integer}]

  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end
  
  def Runner.load_from_array(array_runners)
    ar = Array.new
    array_runners.each do |runner|
      obj = Runner.new
      @@vars.each do |symvar|
        varname = BetfairHelpers.marketDataVar(symvar)
        val_from_xml = runner.send(varname)
        var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
        obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
      end
      ar << obj
    end
    ar
  end


end

class MarketData
  include BetfairHelpers
  @@vars = [ {:market_id => :integer}, :market_name, :market_type, :market_status, {:event_date => :datetime}, :menu_path, :event_hierarchy,
             :bet_delay, {:exchange_id => :integer } , :country_code, {:last_refresh => :datetime }, {:n_runner => :integer} , {:n_winners => :integer},
             {:amount => :double},{:bsp_market => :boolean} ,{:tplay => :boolean }]
  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end

  def MarketData.from_string(str)
    $logger.debug "loading MarketData for #{str}"
    fields = str.split("~")
    obj = MarketData.new
    if fields.size != @@vars.size
      $logger.error 'Error on MarketData#from_string'
      $logger.error "In string: #{str}"
      $logger.error 'Mal formed line, size differs: ' + str.to_s 
      return nil
      # raise 'Mal formed line, size differs: ' + str.to_s 
    end
    @@vars.each_with_index do |var,index|
      obj.instance_variable_set( ("@" + BetfairHelpers.marketDataVar(var).to_s).to_sym, BetfairHelpers.build_bf_var(var,fields[index]))
    end
    $logger.debug "obj with #{obj.inspect}"
    obj
  end
end

