require 'cgi'
require 'ipaddr'
require 'ostruct'

module Kafkaesque
  class Event

    URI_PATTERN = /^\/[kw]\/([^\/]+)\/$/

    attr_reader :payload, :game, :stamp, :uri, :params, :ip

    def initialize(payload)
      @payload = payload
      @game, @ip, @stamp, @uri, @params = payload.split(' ')
      @params = Event.parse(params)
      @stamp = stamp.to_i
      if params[:w_ip]
        @ip_numeric = params[:w_ip].to_i
        @ip = int_to_ip(@ip_numeric)
      end
    end

    def time
      @time ||= Time.at(stamp)
    end

    def city
      location.city_name
    end

    def country
      location.country_code2
    end

    def call
      @call ||= fetch_call
    end

    def ip_numeric
      @ip_numeric ||= ip_to_int(@ip)
    end

  private

    def self.parse(query)
      params = {}
      return params unless query
      query.split('&').each do |pairs|
        key, value = pairs.split('=').map {|v| CGI::unescape(v) if v }
        params[key.to_sym] = value if key && value
      end
      params
    end

    def location
      @location ||= fetch_location
    end

    def ip_to_int(ip)
      IPAddr.new(ip).to_i
    end

    def int_to_ip(i)
      IPAddr.new(i, Socket::AF_INET).to_s
    end

    def fetch_location
      (Kafkaesque.geoip && Kafkaesque.geoip.country(@ip)) || OpenStruct.new(:city_name => nil, :country_code2 => nil)
    end

    def fetch_call
      $1 if @uri =~ URI_PATTERN
    end

  end
end