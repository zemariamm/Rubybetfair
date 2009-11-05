require 'rubygems'
require 'encoding/character/utf-8'

class Proc

  def uStringMethods()
    umethods = []
    Encoding::Character::UTF8.methods.each do |m|    
      umethods.push(%!
          define_method("u#{m}") do |*args|
            Encoding::Character::UTF8.#{m}(self, *args)
          end  # unless instance_methods.include?("u#{m}")
        !)
    end

    #puts umethods
    umethods = umethods.reject { |m| m =~ /taguri/ }

    String.class_eval(umethods.join)
  end

end


Proc.new {}.uStringMethods()     #  adds methods defined in module Encoding::Character::UTF8::Methods to class String

module BetfairHelpers

  def api_request_header(sessionToken)
    hash = {:header => {:clientStamp => 0, :sessionToken => sessionToken}}
    return hash
  end

  
  def enum?(obj)
    obj.is_a? Enumerable
  end

  def check_required_vars(hash,consts)
    if enum?(consts)
      all_present = consts.collect { |elem| hash.keys.include?(elem) && hash[elem] != nil }
      raise 'Missing values!!!! ' if all_present.include? false
      return true
    else
      return true if (hash.keys.include?(consts) && hash[consts] != nil)
      raise 'Missing value: ' + consts.to_s
    end
  end


  def load_defaults(hash,hashdefaults)
    newhash = hash.clone
    hashdefaults.keys.each { |elem| newhash[elem] = hashdefaults[elem] if hash[elem].nil? }
    newhash
  end

  def w3c_date(date) date.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00") end


  
  # build Betfair Variable
  # builds a variable according to the type defined in Betfair's WSDL
  def build_bf_var(var, value)
    # varbf = marketDataVar(var)

    typebf = marketDataType(var)
    ret = nil
    if (typebf == :string)
      ret = value.to_s
    elsif (typebf == :datetime)
      ret = Time.at(value.to_i / 1000)
    elsif (typebf == :integer)
      ret = value.to_i
    elsif (typebf == :double)
      ret = value.to_f
    elsif (typebf == :boolean)
      if (value.to_s.casecmp("Y") == 0 || value.to_s.casecmp("true") == 0)
        ret = true
      elsif (value.to_s.casecmp("N") == 0 || value.to_s.casecmp("false") == 0 )
        ret = false
      else
        raise "Error cant convert value to boolean: #{value} with class #{value.class}"
      end
    elsif (typebf == :array)
      if (value.respond_to? :to_a)
        ret = value.to_a
      else
        ret = [value]
      end
    else
      raise "Type: " + typebf.to_s + " not implemented yet"
    end
    ret
  end
  
  # Extract a var from a tuple
  # if it's not a tuple, just returns the same var
  # see example MarketData::from_string
  def marketDataVar(var)
    if var.kind_of? Hash
      raise 'Mal formed var ' + var.inspect.to_s if (var.keys.size != 1 || var.values.size != 1)
      return var.keys[0]
    else
      return var
    end    
  end

  # extracts the kind of variable from a tuple
  # default is String
  def marketDataType(var)
    if var.kind_of? Hash
      raise 'Mal formed var ' + var.inspect.to_s if (var.keys.size != 1 || var.values.size != 1)
      return var.values[0]
    end
    # default type is String
    return :string
  end

  module_function :marketDataVar, :marketDataType, :enum?, :build_bf_var, :w3c_date

end
