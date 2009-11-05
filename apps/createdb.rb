require 'rubygems'
require 'activerecord'

ActiveRecord::Base.establish_connection(
                                        #:adapter => "jdbcmysql",
                                        :adapter => "mysql",
                                        :host => "localhost",
                                        :username => "root",
                                        :database => "betfair")


class Initial < ActiveRecord::Migration

  def self.up

    # has_many :runners
    # has_many :market_prices
    # Ids com CamelCase e porque vem da API


    create_table('markets') do |t|
      t.column 'bsp_market' , :boolean
      t.column 'country_iso3', :string
      # coupounLinks missing
      t.column 'discount' , :boolean
      # missing eventHierarchy
      t.column 'eventHierarchy', :string
      t.column 'eventTypeId', :integer
      t.column 'interval', :integer
      t.column 'last_refresh', :integer
      t.column 'licenseId', :integer
      t.column 'market_base_rate', :double
      t.column 'market_description', :string
      t.column 'market_display_time', :datetime
      t.column 'marketId', :integer
      t.column 'market_status', :string
      t.column 'market_suspend_time', :datetime
      t.column 'market_time' , :string
      t.column 'market_type', :string
      t.column 'market_type_variant', :string
      t.column 'max_unit_value', :integer
      t.column 'menu_path', :string
      t.column 'min_unit_value', :integer
      t.column 'name', :string
      t.column 'number_of_winners', :integer
      t.column 'parentEventId', :integer
      #runners missing
      t.column 'runners_may_be_added' , :boolean
      t.column 'timezone', :string
      t.column 'unit', :integer
    end


    # has_many :runner_extras
    # has_one :market
    create_table('runners') do |t|
      t.column 'name', :string
      t.column 'asianLineId', :integer
      t.column 'handicap', :double
      t.column 'selectionId', :integer
      t.column 'market_id' , :integer
    end

    # belongs_to :market

    create_table('market_prices') do |t|
      t.column 'market_id', :integer
      t.column 'marketId', :integer
      t.column 'currency' , :string
      t.column 'market_status', :string
      t.column 'inplay_delay' , :integer
      t.column 'number_winners' , :integer
      t.column 'market_info' , :integer
      t.column 'discount' , :boolean , :default => false
      t.column 'market_base_rate' , :string
      t.column 'refresh', :integer
      t.column 'bsp', :boolean , :default => false
      t.column 'created_at', :datetime
    end


    # belongs_to market_price
    # belongs_to runner_extra
    create_table('bets') do |t|
      t.column 'tipo' , :string , :null => false
      t.column 'amountAvailable', :double ,:default => 0.0
      t.column 'price', :double, :null => false
      t.column 'market_price_id', :integer
      t.column 'runner_extra_id', :integer
      t.column 'created_at', :datetime
      t.column 'time_betfair', :datetime
    end

    # has_one :runner
    create_table('runner_extras') do |t|
      t.column 'runner_id', :integer
      t.column 'selectionId' , :integer
      t.column 'order_index' , :integer
      t.column 'total_amount_matched' , :double 
      t.column 'last_price_matched' , :double
      t.column 'handicap', :double , :null => true
      t.column 'reduction_factor', :double
      t.column 'vacant' , :boolean , :null => true
      t.column 'far_price', :double
      t.column 'near_price', :double
      t.column 'actual_price', :double
      t.column 'created_at', :datetime
      t.column 'name', :string
    end
  end


  def self.down
    drop_table :markets
    drop_table :runners
    drop_table :market_prices
    drop_table :bets
    drop_table :runner_extras
  end

end

Initial.migrate(:up)
