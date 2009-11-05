require 'rubygems'
# require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
# require File.join(File.dirname(__FILE__)) + '/../utils/vardef_dsl.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'
require 'activesupport'

class BetDriver < BetfairContainer
  include BetfairHelpers
  @@dbetTypesIncluded ="S"
=begin
"C" Cancelled
"L" Lapsed
"M" Matched
"MU" Match and Unmatched
"S" Settle
"U" Unmatched
=end
  @@ddetailed=true # true or false
  @@deventTypeIds=[2]
=begin
2 for Tenis
Event types to return. For matched and 
unmatched bets only, you can submit an empty 
array, “<eventTypeIds></eventTypeIds>”, and 
specify zero as the marketId to receive records 
of all your bets on the exchange. See Table 15- 
2 on page 43. 
=end  
  @@dmarketId=0
=begin
Returns the records of your matched or 
unmatched bets for the specified market. If you 
use this parameter you must submit an empty 
eventTypeId array 
“<eventTypeIds></eventTypeIds>” 
Note that, if you specify a marketId, you must 
also specify either M or U as the value for the 
betTypesIncluded parameter (see above in this 
table). See Table 15-2 on page 43.
=end
  @@dlocale=nil
  @@dtimezone=nil
  @@dmarketTypesIncluded=["O"]
=begin
Array of
"A" - Asian Handicap
"L" - Line
"O" - Odds
"R" - Range
"NOT_APPLICABLE" - The market does not have an applicable market type 
=end
  @@dplacedDateFrom = BetfairHelpers.w3c_date(Time.now - 10.year)
  @@dplacedDateTo = BetfairHelpers.w3c_date(Time.now)
  @@drecordCount = 10
  @@dsortBetsBy = "BET_ID"
=begin
"BET_ID" Order by Bet ID 
"CANCELLED_DATE" Order by Cancelled Date
"MARKET_NAME" Order by Market Name
"MATCHED_DATE" Order by Matched Date 
"NONE" Default order 
"PLACED_DATE" Order by Placed Date
=end
  @@dstartRecord = 0

  def initialize(bfdriver)
    super(bfdriver)
  end

  def getBetHistory(options = {})
    packet = load_defaults(options, {:betTypesIncluded => @@dbetTypesIncluded,
                             :detailed => @@ddetailed,
                             :eventTypeIds => @@deventTypeIds,
                             :marketId => @@dmarketId,
                             :locale => @@dlocale,
                             :timezone => @@dtimezone,
                             :marketTypesIncluded => @@dmarketTypesIncluded,
                             :placedDateFrom => @@dplacedDateFrom,
                             :placedDateTo => @@dplacedDateTo,
                             :recordCount => @@drecordCount,
                             :sortBetsBy => @@dsortBetsBy,
                             :startRecord => @@dstartRecord })
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling getBetHistory with #{packet.inspect.to_s}"
      driver.getBetHistory(:request => packet)
    end
    ans.result.betHistoryItems.bet.collect { |betxml| Bet.fromXml(betxml) }
  end

  # nome do jogo
  # nome do evento
  # outcome - o resultado que tu queres
  def placeBets(options = {})
    ar = {:asianLineId => 0, 
      :betCategoryType => "E", 
      :betPersistenceType =>"NONE", 
      :betType => "B",
      :bspLiability => 2.0,
      :marketId => 97383,
      :price => 2.0,
      :selectionId => 1,
      :size => 1 }
    packet = {:bets => [ar]}
    ans = execute_remote(:exchange_uk) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling placeBets with #{packet.inspect.to_s}"
      driver.placeBets(:request => packet)
    end
    
  end


end

class Bet
  include BetfairHelpers
  
  var :asianLineId, :integer
  var :avgPrice, :double
  var :betCategoryType
  var :betId, :integer
  var :betPersistenceType
  var :betStatus
  var :betType
  var :bspLiability, :double
  var :cancelledDate, :datetime
  var :executedBy
  var :fullMarketName
  var :handicap, :double
  var :lapsedDate, :datetime
  var :marketId, :integer
  var :marketName
  var :marketType
  var :marketTypeVariant
  var :matchedDate, :datetime
  var :matchedSize, :double
  var :matches, :array
  var :placedDate, :datetime
  var :price,:double
  var :profitAndLoss, :double
  var :remainingSize, :double
  var :requestedSize, :double
  var :selectionId, :integer
  var :selectionName
  var :settledDate, :datetime
  var :voidedDate, :datetime

  def Bet.fromXml(values)
    obj = Bet.new
    $logger.info "Calling Bet#fromXml with values: #{values.inspect}"
    # $logger.debug "Values.matches.match: #{values.matches.match.inspect}"
    Bet.get_vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      if (varname.to_sym != :matches)
        val_from_xml = values[varname.to_s]
        var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
        obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value)
      else
        $logger.info "Values.matches #{values.matches.inspect}"
        #puts "***************************************************"
        # puts values["betId"]
        # puts values.inspect
        # puts values.matches.inspect
        # puts values.matches.class
        # puts values.matches.match.inspect

        if values.matches.is_a? SOAP::Mapping::Object
          if values.matches.match.kind_of? Enumerable
            values.matches.match.each do |mat|
              $logger.info "Calling Match#fromXMl with #{mat.inspect}"
              var_value = Match.fromXml(mat)
              obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value)
            end
          else
            var_value = Match.fromXml(values.matches.match)
            obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value)
          end
        else
          obj.instance_variable_set( ("@" + varname.to_s).to_sym,[])
        end
      end
    end
    obj
  end
end

class Match
  include BetfairHelpers

  var :betStatus
  var :matchedDate, :datetime
  var :priceMatched, :double
  var :profitLoss, :double
  var :settledDate, :datetime
  var :sizeMatched, :double
  var :transactionId, :integer
  var :voidedDate, :datetime
  
  def Match.fromXml(values)
    obj = Match.new
    $logger.info "Calling Match#fromHash with values: #{values.inspect}"
    Match.get_vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = values[varname.to_s]
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value)
    end
    obj
  end

end
