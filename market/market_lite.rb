require 'rubygems'
# require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'
# require File.join(File.dirname(__FILE__)) + '/market.rb'

class MarketLite
  include BetfairHelpers

  @@vars = [
            {:delay => :integer},
            :marketStatus,
            {:marketSuspendTime => :datetime },
            {:marketTime => :datetime},
            {:numberOfRunners => :integer},
            {:openForBspBetting => :boolean} ]
  
  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end
  

  def MarketLite.fromXml(marketlite_xml)
    obj = MarketLite.new
    $logger.info "Create MarketLite Object from #{marketlite_xml}"
    $logger.warn "E preciso ver o problema dos objectos datetime"
    @@vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = marketlite_xml.send(varname)
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
    end
    obj
  end


end

