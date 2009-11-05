require 'rubygems'
#require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'
#require File.join(File.dirname(__FILE__)) + '/market.rb'

class AvailableMarketDepth 
  include BetfairHelpers

  @@vars = [ {:priceItems => :array } ]

  attr_accessor :priceItems
  
  def AvailableMarketDepth.fromXml(priceitems_xml)
    obj = AvailableMarketDepth.new
    obj.priceItems = Array.new
    
    if priceitems_xml.availabilityInfo.kind_of? Enumerable
      priceitems_xml.availabilityInfo.each do |ainfo|
        obj.priceItems << AvailibilityInfo.fromHash(ainfo)
      end
    else
      obj.priceItems << AvailibilityInfo.fromHash(priceitems_xml.availabilityInfo)
    end
    obj
  end
end


class AvailibilityInfo 
  include BetfairHelpers
  
  @@vars = [
            {:odds => :double},
            {:totalAvailableBackAmount => :double},
            {:totalAvailableLayAmount => :double },
            {:totalBspBackAmount => :double },
            {:totalBspLayAmount => :double} ]

  @@vars.each do |symvar| 
    vary = BetfairHelpers.marketDataVar(symvar)
    attr_accessor vary
  end
  


  def AvailibilityInfo.fromHash(values)
    $logger.info "Calling AvailibilityInfo#fromHash with values: #{values.inspect}"
    $logger.warn "Not checking for missing fields in AvailibilityInfo"
    obj = AvailibilityInfo.new
    @@vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = values.send(varname.to_sym)
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
    end
    obj
  end

end

