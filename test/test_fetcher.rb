require 'helper'

class TestFetcher < Test::Unit::TestCase

  class FakeKafkaClient
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


  context "fetcher" do
    setup do
      @queue = java.util.concurrent.ArrayBlockingQueue.new(20)
    end
    
    should "queue only messages which match filter" do
      config = Hash[:handler => String, :selection_filter => /^(3|4)$/]
      Kafkaesque::Fetcher.expects(:create_redis_client).with(config).returns(stub('redis', :hset => nil, :hget => nil))
      Kafkaesque::Fetcher.expects(:create_kafka_client).with(config, 'a', nil).returns(FakeKafkaClient.new('a'))
      fetcher = Kafkaesque::Fetcher.new(@queue, 'a', config)
      Thread.new do
        sleep 0.1
        Kafkaesque::Consumer.stop
      end
      fetcher.do_fetch
      assert_equal 2, @queue.length
      assert_equal "a 127.0.0.1 1234 /w/3/", @queue.take
      assert_equal "a 127.0.0.1 1234 /w/4/", @queue.take
    end

    should "return if stop is requested" do
      config = Hash[:handler => String]
      Kafkaesque::Consumer.stop
      Kafkaesque::Fetcher.expects(:create_redis_client).with(config).returns(stub('redis', :hset => nil, :hget => nil))
      Kafkaesque::Fetcher.expects(:create_kafka_client).with(config, 'a', nil).returns(FakeKafkaClient.new('a'))
      fetcher = Kafkaesque::Fetcher.new(@queue, 'a', config)
      fetcher.do_fetch

      assert_equal 1, @queue.length
      assert_equal "a 127.0.0.1 1234 /w/0/", @queue.take
    end
    
    should "start with offset nil when no offset is stored in redis" do
      config = Hash[:handler => String]
      Kafkaesque::Consumer.stop
      Kafkaesque::Fetcher.expects(:create_redis_client).with(config).returns(stub('redis', :hset => nil, :hget => nil))
      Kafkaesque::Fetcher.expects(:create_kafka_client).with(config, 'a', nil).returns(FakeKafkaClient.new('a'))
      fetcher = Kafkaesque::Fetcher.new(@queue, 'a', config)
      fetcher.do_fetch
    end

    should "start with offset stored in redis" do
      config = Hash[:handler => String]
      Kafkaesque::Consumer.stop
      redis = stub('redis')
      redis.expects(:hget).with("string", "a").returns("12")
      redis.expects(:hset).returns(nil)
      
      Kafkaesque::Fetcher.expects(:create_redis_client).with(config).returns(redis)
      Kafkaesque::Fetcher.expects(:create_kafka_client).with(config, 'a', 12).returns(FakeKafkaClient.new('a', 12))
      fetcher = Kafkaesque::Fetcher.new(@queue, 'a', config)
      fetcher.do_fetch
    end

    should "store offset in redis after each loop" do
      config = Hash[:handler => String]
      Kafkaesque::Consumer.stop
      redis = stub('redis')
      redis.expects(:hget).returns("12")
      redis.expects(:hset).with("string", "a", 12).returns(nil)
      
      Kafkaesque::Fetcher.expects(:create_redis_client).with(config).returns(redis)
      Kafkaesque::Fetcher.expects(:create_kafka_client).with(config, 'a', 12).returns(FakeKafkaClient.new('a', 12))
      fetcher = Kafkaesque::Fetcher.new(@queue, 'a', config)
      fetcher.do_fetch
    end
  end

end

