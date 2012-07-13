require File.dirname(__FILE__) + '/helper'
require 'ostruct'

class TestConsumer < Test::Unit::TestCase
  class FakeKafkaClientTestConsumer
    attr_reader :offset

    def initialize(topic, offset = 0)
      @offset, @topic = offset, topic
    end

    def loop
      while(true) do
        yield [OpenStruct.new(:payload => "127.0.0.1 1234 /w/#{@offset}/")]
        @offset += 1
        sleep(0.01)
      end
    end
  end

  class WorkerSameThread
    def initialize(config)
      Thread.current[:something] = { :some => :value }
    end

    def handle(event)
      raise "NOT RUNNING IN SAME THREAD" if Thread.current[:something][:some] != :value
      puts "Doing Handling of Test Event"
    end
  end

  context "consumer" do
    should "spawn worker in the same thread as doing the work" do
      config = {
        :handler => WorkerSameThread,
        :kafka => {
          :topics => ["one"]
        },
        :number_of_workers => 1
      }

      Kafkaesque::Fetcher.expects(:create_redis_client).with(config).
        returns(stub('redis', :hset => nil, :hget => nil))
      Kafkaesque::Fetcher.expects(:create_kafka_client).with(config, 'one', nil).
        returns(FakeKafkaClientTestConsumer.new('one'))

      consumer = Kafkaesque::Consumer.new(config)
      t = Thread.new do
        sleep 0.1
        consumer.queue.put(:stop)
        Kafkaesque::Consumer.stop
      end

      _,stdout,_ = silence_is_golden do
        consumer.start
      end

      t.join

      assert_match /Doing Handling of Test Event/, stdout
      assert_no_match /NOT RUNNING IN SAME THREAD/, stdout
    end
  end
end
