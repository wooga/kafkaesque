require 'cgi'
require 'ipaddr'
require 'ostruct'

module Kafkaesque
  class Event

    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

  end
end