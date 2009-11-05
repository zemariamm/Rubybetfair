$KCODE ='u'
require 'rubygems'
require 'jcode'
require 'socket'
require 'drb'
THIS_DIR = File.expand_path(File.dirname(__FILE__))
require File.join(File.dirname(__FILE__)) + '/../includes.rb'
Dir.chdir(THIS_DIR)
puts THIS_DIR
# lousy hack
# require 'apps/models.rb'

# 20 euros
MIN_PRICE=20.0

def send_string(sock, str)
  str = str + "\n"
  begin
    while str.length > 0
      sent = sock.send(str, 0)
      str = str[sent..-1]
    end
  rescue IOError, SocketError, SystemCallError
    # eof = true
  end
end

def clean(str)
  return str.gsub(" ","").gsub("s","5").gsub("c","0").gsub("e","0").gsub("o","0").gsub("i","l").gsub("m","h").gsub("n","h").gsub(",",".")
end

def find_best_fit(ar)
  # get worst price
  ar.sort! do |elem1,elem2|
    elem2[0] <=> elem1[0]
  end
  bodd = ar[ar.size - 1][0]
  bmoney = ar[ar.size - 1][1]
  ar.each do |elem|
    auxodd = elem[0]
    money = elem[1]
    if money > MIN_PRICE && auxodd > bodd
      #puts "Bet: #{auxodd}"
      #puts "price: #{money}"
      bodd = auxodd
      bmoney = money
    end
  end
  raise "Market does not have enough money: #{ar.inspect}" if bmoney < MIN_PRICE
  bodd
end

class BestRunnerOdd
  attr_accessor :runner, :odd
  def initialize(_runner, _odd)
    self.runner = _runner
    self.odd = _odd
  end

  def found_diff(ar)
    max = find_best_fit(ar)
    if self.odd != max
      self.odd = max
      return self
    else
      return false
    end
  end
end

class BestBet
  # Possibles values for market 
  attr_accessor :gamename, :marketname, :marketstatus
  attr_accessor :marketdriver
  attr_accessor :brunnerodds
  attr_accessor :socket
  attr_accessor :database
  attr_accessor :queue
  
  # private var holding the market loaded from Betfair
  attr_accessor :marketId
  def initialize(_gamename,_marketname,_marketdriver,_socket)
    self.gamename = _gamename
    self.marketname = _marketname
    self.marketdriver = _marketdriver
    self.brunnerodds = Hash.new
    self.socket = _socket
    self.marketstatus = :not_in_server
    self.queue = Queue.new
    #self.database = DBUtils.new
  end



  def load
    markets = marketdriver.search_by_game_name(self.gamename)
    smarket = markets.find_all{ |md| md.market_name.casecmp(self.marketname) == 0 }
    raise "Problem with game #{self.gamename} in market: #{self.marketname}" if smarket.size != 1
    self.marketId = smarket[0].market_id
    # fist call with getMaket to extract runners name
    md = self.marketdriver.getMarket(:marketId => self.marketId)

    # self.database.add_market(md)
    # self.queue.push md
    
    md.runners.each do |runner|
      self.brunnerodds[runner.selectionId] = BestRunnerOdd.new(runner,-10000)
      odds_prices = extract_odds_prices_getmarket(runner)
      prunner = self.brunnerodds[runner.selectionId].found_diff(odds_prices)
      self.brunnerodds[runner.selectionId] = prunner if prunner
    end
    send_xml("a")
    self.marketstatus = :in_server
  end

  def extract_odds_prices_getmarket(runner)
    prices = self.marketdriver.getDetailAvailableMarketDepth({:marketId => self.marketId, :selectionId => runner.selectionId})
    return prices.priceItems.collect { |ainfo| [ ainfo.odds , ainfo.totalAvailableBackAmount] }
  end


  def check_changes
    md = self.marketdriver.getMarketPricesCompressed(:marketId => self.marketId)
    #DBUtils.add_market_price_compressed(md)
    # self.database.add_market_price_compressed(md)
    self.queue.push md
    any_change = false
    md.runnerInfo.each do |runner|
      odds_prices = extract_odds_prices(runner)
      #puts "self.brunnerodds[runner.selectionId].runner.selectionId"
      #puts "Comparing #{self.brunnerodds[runner.selectionId].odd} With:"
      #puts odds_prices.inspect
      prunner = self.brunnerodds[runner.selectionId].found_diff(odds_prices)
      if prunner
        self.brunnerodds[runner.selectionId] = prunner 
        any_change = true if prunner
      end
    end
    any_change
  end

  def extract_odds_prices(runner)
    odds = runner.odds.find_all {|odd| odd.type.casecmp("L") == 0 }
    return odds.collect { |odd| [odd.price , odd.amountAvailable ] }
  end

  def watch(sleeptime = 20)
    Thread.new do
      loop do
        # puts "press key"
        # s = gets
        sleep sleeptime
        # md = self.marketdriver.getMarket(:marketId => self.marketId)
        begin
          val = check_changes
          if val
            # puts self.to_xml
            # self.socket.puts self.to_xml
            if self.marketstatus == :not_in_server
              puts "Sending with 'Add'"
              send_xml("a")
            else
              send_xml
            end
            self.marketstatus = :in_server
          else
            #puts "no change"
          end
        rescue Exception => detail
          # problem in market, cancel market
          puts detail.inspect
          cancel_market
        end
      end
    end
  end
  
  def to_s
    str = ""
    self.brunnerodds.keys.each do |key|
      str += "#{self.brunnerodds[key].runner.selectionId} : #{self.brunnerodds[key].odd}\n"
    end
    str
  end

  def send_auth
    xml = "<msg type='i'>BetFair</msg>"
    puts "Sending: #{xml}"
    send_string(self.socket,xml)
  end

  def send_xml(mode="u")
    xml = to_xml(mode)
    puts xml

    send_string(self.socket,xml)
    self.socket.flush
  end


  def cancel_market
    if self.marketstatus == :in_server
      xml = cancel_market_xml
      puts xml.to_s + " REMOVED ".to_s
      send_string(self.socket,xml)
      self.socket.flush
      self.marketstatus = :not_in_server
    end
  end

  def cancel_market_xml
    event = get_event_name
    xml = "<msg type = '" + "r" + "'>"
    # xml += "<game>" + self.gamename + "</game>"
    xml += "<game>" + "tennis" + "</game>"
    xml += "<event>" + clean(event) + "</event>"
    xml += "</msg>"
    xml
  end


  def get_event_name
    dic = { "Match Odds" => "winner" }
    event = dic[self.marketname]
    event = "winner" if event.nil?
    event
  end


  # 'a' -> add
  # 'u' -> update
  # 'r' -> remove
  def to_xml(mode="u")
=begin
    dic = { "Match Odds" => "winner" }
    event = dic[self.marketname]
    event = "winner" if event.nil?
=end
    event = get_event_name
    xml = "<msg type = '" + "#{mode}" + "'>"
    # xml += "<game>" + self.gamename + "</game>"
    xml += "<game>" + "tennis" + "</game>"
    xml += "<event>" + clean(event) + "</event>"
    xml += "<outcomes>"
    self.brunnerodds.keys.each do |key|
      outcome = self.brunnerodds[key]
      name = outcome.runner.name.to_s
      name = clean(name)
      xml += "<outcome name = '" + name + "'>" + outcome.odd.to_s + "</outcome>"
    end
    xml += "</outcomes>"
    xml += "</msg>"
    xml
  end
  
end

betfair_driver = CommonBetfair.new
user = User.new(betfair_driver, {:username => 'subs', :password => '*****'})
user.login

market = MarketDriver.new(betfair_driver)
# t = TCPSocket.open("127.0.0.1",1521)
t = TCPSocket.open("127.0.0.1",8080)
# t = 1
obj = BestBet.new("Cirstea v Dulko", "Match Odds",market,t)
obj.send_auth
obj.load
obj.watch(1)

DRb.start_service('druby://:1234',obj)
DRb.thread.join
