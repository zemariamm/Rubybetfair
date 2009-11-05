require 'rubygems'
# require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'


class EventDriver < BetfairContainer
  include BetfairHelpers
  @@dlocale = nil

  def initialize(bfdriver)
    super(bfdriver)
  end


  def getActiveEventTypes(options = {} )
    packet = load_defaults(options, { :locale => @@dlocale })
    ans = execute_remote(:global) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling getActiveEventTypes with #{packet.inspect.to_s}"
      driver.getActiveEventTypes(:request => packet)
    end
    ans
  end

  def getAllEventTypes(options = {} )
    packet = load_defaults(options, { :locale => @@dlocale })
    ans = execute_remote(:global) do |driver|
      header = get_api_req_header
      packet = packet.merge(header)
      $logger.info "Calling getActiveEventTypes with #{packet.inspect.to_s}"
      driver.getAllEventTypes(:request => packet)
    end
    ans.result.eventTypeItems.eventType.collect { |et| EventType.fromHash(et) }
  end

end

class EventType
  include BetfairHelpers
  
  @@vars = [
            { :id => :integer },
            :name,
            {:nextMarketId => :integer },
            :exchangeId ]
  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end

  def EventType.fromHash(values)
    obj = EventType.new
    $logger.info "Calling EventType#fromHash with values: #{values.inspect}"
    @@vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = values[varname.to_s]
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value)
    end
    obj
  end
end
