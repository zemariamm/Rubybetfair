require 'rubygems'
require 'soap/wsdlDriver'
# require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require File.join(File.dirname(__FILE__)) + '/common.rb'

class User < BetfairContainer
  include BetfairHelpers

  @@dproductId = 82
  @@dvendorSoftwareId = 0
  @@dipAddress = "0"
  @@dlocationId = 0

  
  
  @@vars_betfair = [:username,:password,:productId, :locationId,:vendorSoftwareId,:ipAddress]

  @@vars_betfair.each { |val| attr_accessor val }

  attr_accessor :driver_global, :login_details, :currency
  attr_accessor :loggedin

  def initialize(bfdriver,options = {})
    super(bfdriver)
    self.loggedin = false
    check_required_vars(options,[:username,:password])
    options = load_defaults(options, { 
                              :productId =>  @@dproductId,
                              :locationId => @@dlocationId,
                              :vendorSoftwareId => @@dvendorSoftwareId,
                              :ipAddress => @@dipAddress })
    self.login_details = options.clone
    @@vars_betfair.each do |elem|
      str = "self." + elem.to_s + "=" + "options[elem]"
      eval(str)
    end
  end


  def login
    $logger.info "Trying to login with #{self.login_details.inspect.to_s}"
    lastans = execute_remote(:global) { |driver| driver.login(:request => self.login_details) }
    # puts lastans.inspect
    load_currency(lastans.result.currency)
    self.loggedin = true
  end


  def logout
    $logger.info "Calling User#logout"
    execute_remote(:global) { |driver| driver.logout(:request => get_api_req_header) }
  end

  def logged_in?
    return self.loggedin
  end

  def keepAlive
    $logger.info "Calling User#keepAlive"
    execute_remote(:global) { |driver| driver.keepAlive(:request => get_api_req_header ) }
  end


  def load_currency(val)
    self.currency = val
  end

  
end

