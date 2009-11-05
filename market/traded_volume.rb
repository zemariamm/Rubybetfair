require 'rubygems'
#require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/../base/common.rb'
#require File.join(File.dirname(__FILE__)) + '/market.rb'

class TradedVolume
  include BetfairHelpers

  @@vars = [ 
            {:priceItems => :array },
            {:actualBSP => :double} ]

  attr_accessor :actualBSP, :priceItems
  


  def TradedVolume.fromXml(response)
    # puts response.inspect
    obj = TradedVolume.new
    obj.actualBSP = response.send(:actualBSP).to_f
    obj.priceItems = Array.new
    
    #puts response.priceItems.inspect
    response.priceItems.volumeInfo.each do |ainfo|
      # puts ainfo.inspect
      obj.priceItems << VolumeInfo.fromHash(ainfo)
    end
    obj
  end

end

class VolumeInfo 
  include BetfairHelpers
  
  @@vars = [
            {:odds => :double},
            {:totalMatchedAmount => :double},
            {:totalBspBackMatchedAmount => :double },
            {:totalBspLiabilityMatchedAmount => :double } ]


  def VolumeInfo.fromHash(values)
    $logger.info "Calling VolumeInfo#fromHash with values: #{values.inspect}"
    $logger.warn "Not checking for missing fields in VolumeInfo"
    obj = VolumeInfo.new
    @@vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = values.send(varname.to_sym)
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value )
    end
    obj
  end

end
