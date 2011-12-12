module Kafkaesque
  class Fetcher

    MESSAGE_PATTERN = /^[^ ]+ [^ ]+ \/[kw]\/([^\/]+)\//

    def initialize(queue, topic, config)
      @queue = queue
      @topic = topic
      @config = config
      @redis  = Fetcher.create_redis_client(config)
      offset = (@redis.hget(offset_key, topic) || -1).to_i
      @kafka  = Fetcher.create_kafka_client(config, topic, offset)
      @filter = config[:selection_filter]
    end

    def do_fetch
      @kafka.loop do |messages|
        messages.each do |message|
          @queue.put("#{@topic} #{message.payload}") if select(message.payload)
        end
        @redis.hset(offset_key, @topic, @kafka.offset)
        return if Consumer.stop_requested?
      end
    end

  private

    def select(message_string)
      return true unless @filter
      call = $1 if message_string =~ MESSAGE_PATTERN
      return call =~ @filter
    end

    def offset_key
      "#{@config[:handler].name.downcase}"
    end

    def self.create_kafka_client(config, topic, offset)
      Kafka::Consumer.new(
        :host => config[:kafka][:host],
        :topic => topic,
        :offset => offset,
        :polling => 1
      )
    end

    def self.create_redis_client(config)
      Redis.new(:host => config[:kafka][:host], :db => 15)
    end

  end
end

