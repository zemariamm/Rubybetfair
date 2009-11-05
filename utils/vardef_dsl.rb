require File.join(File.dirname(__FILE__)) + '/utils.rb'

class Class
  def get_vars
    if self.instance_variable_defined? :@vars
      @vars
    else
      @vars = Array.new
      @vars
    end
  end

  def add_var(name,type)
    list = get_vars
    already_present = list.detect do |symvar|
      name.to_sym == BetfairHelpers.marketDataVar(symvar).to_sym
    end
    raise "Variable #{name} already defined" if already_present
    list << {name => type }

    define_method name do
      instance_variable_get "@#{name}"
    end
    
    define_method "#{name}=" do |newval|
      instance_variable_set "@#{name}", newval
    end

  end

  def var(name,type = :string)
    add_var(name,type)
    # puts "Added #{name} with type: #{type}"
  end

end
=begin
class Test
  var :nome, :string
  var :age, :integer
  var :local
  
  def initialize
    self.age = 30
    self.nome = 10
    puts self.nome
  end

  def Test.fromHash(values)
    obj = Test.new
    Test.get_vars.each do |symvar|
      varname = BetfairHelpers.marketDataVar(symvar)
      val_from_xml = values[varname.to_s]
      var_value = BetfairHelpers.build_bf_var(symvar,val_from_xml)
      obj.instance_variable_set( ("@" + varname.to_s).to_sym, var_value)
  end
    obj
  end
end
c = Test.fromHash "age" => "40", "nome" => "tiago", "local" => "porto"
p c
=end
=begin
c = Test.new
puts c.inspect
d = Test.new
puts d.inspect
puts Test.get_vars.inspect
=end
