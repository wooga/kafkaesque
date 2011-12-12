require 'rubygems'
require 'java'
require 'kafka'

require File.join(File.dirname(__FILE__), 'kafkaesque', 'event')
require File.join(File.dirname(__FILE__), 'kafkaesque', 'worker')
require File.join(File.dirname(__FILE__), 'kafkaesque', 'fetcher')
require File.join(File.dirname(__FILE__), 'kafkaesque', 'consumer')
require File.join(File.dirname(__FILE__), 'kafkaesque', 'bookings')

# monkey patch: also call block with empty list of messages
Kafka::Consumer.class_eval do
  def loop(&block)
    while(true) do
      messages = self.consume
      block.call(messages || [])
      sleep(self.polling)
    end
  end
end

# clean shutdown on CTRL-C
Signal.trap('INT') do
  Kafkaesque::Consumer.stop
end 

module Kafkaesque

  def self.geoip
    @geoip
  end

  def self.geoip=(geoip)
    @geoip = geoip
  end

end

