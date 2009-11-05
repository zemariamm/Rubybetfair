require 'rubygems'
gem "soap4r"
require 'soap/wsdlDriver'
require File.join(File.dirname(__FILE__)) + '/../utils/utils.rb'
require 'logger'

class BetfairContainer
  attr_accessor :betfair_driver
  
  def initialize(bfobj)
    self.betfair_driver = bfobj
  end

  def execute_remote(option,&b)
    self.betfair_driver.execute_remote(option,b)
  end

  def get_api_req_header
    self.betfair_driver.get_api_req_header
  end
end

class CommonBetfair
  include BetfairHelpers
  @@FREE_ACCESS_API = 82
  @@GLOBAL_SERVICE = File.join(File.dirname(__FILE__)) + "/../wsdls/BFGlobalService.wsdl"
  #puts "Using wsdl: " + @@GLOBAL_SERVICE.to_s
  # "https://api.betfair.com/global/v3/BFGlobalService.wsdl"
  @@UK_EXCHANGE_SERVICE = File.join(File.dirname(__FILE__)) + "/../wsdls/BFExchangeService.wsdl"
  # "https://api.betfair.com/exchange/v5/BFExchangeService.wsdl"
  @@AUS_EXCHANGE_SERVICE = "https://api-au.betfair.com/exchange/v5/BFExchangeService.wsdl"

  attr_accessor :driver_global, :sessionToken, :timestamp, :header, :lastans, :errorCode, :minorErrorCode

  attr_accessor :exchange_uk, :exchange_aus

  def initialize
    $logger = Logger.new(File.join(File.dirname(__FILE__)) + '/../log/runtime.txt')
    $logger.info "Using wsdl file for global service: #{@@GLOBAL_SERVICE}"
    $logger.info "Using wsdl file for UK Exchange service: #{@@UK_EXCHANGE_SERVICE}"
    $logger.info "AUS exchange service turned off, need to add wsdl and load service"
    self.driver_global = SOAP::WSDLDriverFactory.new(@@GLOBAL_SERVICE).create_rpc_driver
    self.exchange_uk = SOAP::WSDLDriverFactory.new(@@UK_EXCHANGE_SERVICE).create_rpc_driver
    # self.exchange_aus = SOAP::WSDLDriverFactory.new(@@AUS_EXCHANGE_SERVICE).create_rpc_driver
  end

  def execute_remote(option,b)
    # puts "Using sessionToken:"
    # puts sessionToken
    case option
      when :global
      $logger.info "Calling global service"
      self.lastans = b.call(self.driver_global)  
      when :exchange_uk
      $logger.info "Calling UK exchange service"
      self.lastans = b.call(self.exchange_uk)
      when :exchange_aus
      $logger.info "Calling Australian exchange service"
      self.lastans = b.call(self.exchange_aus)
    else
      $logger.error "Invalid call to execute_remote, service not valid: #{option}"
      raise 'Invalid parameter: ' + option.to_s
    end
    $logger.debug "With sessionToken: #{self.sessionToken}"
    reload_headers
    check_for_errors
    self.lastans
  end


  def get_api_req_header
    api_request_header(self.sessionToken)
  end

  def reload_headers
    load_header
    load_sessionToken
    load_timestamp
    load_errorCode
  end

  def check_for_errors
    if self.errorCode.casecmp("ok") != 0
      strerror = 'Couldn t make operation: ' + self.errorCode.to_s
      # strerror = "\n With minorErrorCode: " + self.minorErrorCode.to_s
      raise strerror
    end
    true
  end

  def load_header
    self.header = self.lastans.result.header
  end

  def load_sessionToken
      self.sessionToken = self.header.sessionToken
  end    

  def load_errorCode
    if self.lastans.result.header.respond_to? :errorCode
      self.errorCode = self.lastans.result.header.errorCode
    else
      self.errorCode ="ok"
    end
    if self.lastans.result.header.respond_to? :minorErrorCode
      self.minorErrorCode = self.lastans.result.minorErrorCode
    else
      self.minorErrorCode = "ok"
    end
  end

  def load_timestamp
    self.timestamp = self.header.timestamp
  end

end
