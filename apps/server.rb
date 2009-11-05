$KCODE ='u'
require 'rubygems'
require 'jcode'
require 'socket'
require 'xmlsimple'

class BetHouse
  attr_accessor :house
  
  @@houses = ["BetFair","BetClick"]
  
  def initialize(_house)
    self.house = _house
  end

  def certify(str,hash)
    if yield
      puts "ok, testing string: #{str}"
    else
      puts "Error #{str} with: #{hash}"
    end
  end

  def valid?
    # first receive the XML describing which house it is
    # then receive an "Add" house statement
    s = self.house.gets
    name = XmlSimple.xml_in s
    certify(s,name.inspect) { check_presence(name,"type","i") }
    certify(s,name.inspect) do 
      vec = @@houses.collect { |house| check_presence(name,"content",house) }
      vec.include?(true)
    end

    while (s = self.house.gets)
      game = XmlSimple.xml_in s
      certify(s,game.inspect) { check_presence(game,"game") }
    end
  end


  def check_presence(hash,tag,value=nil)
    val_present = true
    tag_present = hash.keys.include?(tag)
    val_present = hash.values.include?(value) if value
    tag_present && val_present
  end



  def close
    self.house.close
  end


end


server = TCPServer.open(8080)
loop do
  id = server.accept
  Thread.new do 
    bet = BetHouse.new(id)
    bet.valid?
    bet.close
  end
end

