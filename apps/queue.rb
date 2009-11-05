require 'rubygems'
require 'drb'


queue = Queue.new

DRb.start_service('druby://:1234',queue)
