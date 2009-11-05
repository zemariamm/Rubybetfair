require 'rubygems'
require File.join(File.dirname(__FILE__)) + '../utils/utils.rb'

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

  
  def getmarkinfo
    marketPricesStrings = str.split(":")
    marketInfoStrings = marketPricesStrings[0].split("~")
    c = 0
    puts "****************************MARKET*********************************"
    puts "MarketID: " + marketInfoStrings[0]
    puts "Currency: " + marketInfoStrings[1]
    puts "MarketStatusEnum: " + marketInfoStrings[2]
    puts "InPlayDelay: " + marketInfoStrings[3]
    puts "N Winners: " + marketInfoStrings[4]
    puts "MarketInfo: " + marketInfoStrings[5]
    puts "Discount: " + marketInfoStrings[6]
    puts "MarketBaseRate: " + marketInfoStrings[7]
    puts "Refresh: " + marketInfoStrings[8]
    puts "RemovedRunnersInfo: " + marketInfoStrings[9]
    puts "BSP: " + marketInfoStrings[10]
    # puts marketPricesStrings[1 ... marketPricesStrings.size].inspect

    marketPricesStrings[1...marketPricesStrings.size].each do |line|
      player_lay_back = line.split("|")
      player = player_lay_back[0]
      player_details = player.split("~")
      puts "~~~~~~~~~~~~~~~~~~~~~Player~~~~~~~~~~~~~~~~~~~~~"
      puts "Selection ID: " + player_details[0]
      puts "Order Index: " + player_details[1]
      puts "Total amount: " + player_details[2]
      puts "Last Price: " + player_details[3]
      puts "Handicap: " + player_details[4]
      puts "Reduction Factor: " + player_details[5]
      puts "Vacant: " + player_details[6]
      puts "FAR SP: " + player_details[7].to_s
      puts "Near SP: " + player_details[8].to_s
      puts "Actual SP: " + player_details[10].to_s

      puts "------------------ ODDS ------------------"
      player_lay_back[1...player_lay_back.size].each do |odd|
        odd_details = odd.split("~")
        # foreach 4 -> one odd
        n = 0
        while (n < odd_details.size)
          puts "Price: " + odd_details[n].to_s
          puts "Amount: " + odd_details[n + 1].to_s
          puts "Type: " + odd_details[n + 2].to_s
          puts "Depth: " + odd_details[n + 3].to_s
          n = n + 4
        end
      end

    end
  end

end



0.upto(151) do |n|
  file = "../tests_prices/test#{n}.txt"

  s = ""
  File.open(file) do |fich|
    s = fich.readlines[0]
  end
  # puts "Using line"
  # puts s
  obj = RexFunctions.new(s)
  # puts "NOW**************"
  # puts obj.str
  #puts "*************************************************************************************"
  obj.getmarkinfo
end
