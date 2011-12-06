require 'helper'

class TestConsumer < Test::Unit::TestCase

  # class FakeKafkaClient
  #   attr_reader :offset
  #
  #   def initialize(topic)
  #     @offset, @topic = 0, topic
  #   end
  #
  #   def loop
  #     while(true) do
  #       yield [OpenStruct.new(:payload => "127.0.0.1 #{@offset} /k/#{@topic}/")]
  #       @offset +=1
  #       sleep(0.1)
  #     end
  #   end
  # end
  #
  # class FakeRedisClient
  #   def hget(key, field)
  #     "0"
  #   end
  #
  #   def hset(key, field, value)
  #     @value = value
  #   end
  # end
  #
  # should "create one kafka client per topic" do
  #   consumer = Kafkaesque::Consumer.new(
  #     :handler => TestHandler,
  #     :kafka => {
  #       :topics => %w[aa bb]
  #     }
  #   )
  #
  #   Thread.new do
  #     sleep(1)
  #     Process.kill("USR2", Process.pid)
  #   end
  #
  #   consumer.expects(:create_redis_client).twice.returns(stub('redis', :hset => nil, :hget => nil))
  #   consumer.expects(:create_kafka_client).with('aa', 0).returns(FakeKafkaClient.new('aa'))
  #   consumer.expects(:create_kafka_client).with('bb', 0).returns(FakeKafkaClient.new('bb'))
  #   consumer.start
  # end

  # class TestHandler
  #   def handle(event)
  #     TestHandler.counter += 1
  #   end
  #
  #   def self.counter
  #     @counter ||= 0
  #   end
  #
  #   def self.counter=(value)
  #     @counter = value
  #   end
  # end

  should "work" do
  end

end