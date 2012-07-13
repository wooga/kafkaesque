require File.dirname(__FILE__) + '/helper'
require 'ostruct'

class TestConsumer < Test::Unit::TestCase
  class WorkerSameThread
    @@thisisfalse = false

    def initialize(config)
      Thread.current[:something] = { :some => :value }
    end

    def self.should_be_true
      @@thisisfalse
    end

    def handle(event)
      @@thisisfalse = (Thread.current[:something][:some] == :value)
    end
  end

  context "consumer" do
    should "spawn worker in the same thread as doing the work" do
      config = {
        :handler => WorkerSameThread,
      }
      assert !WorkerSameThread.should_be_true

      consumer = Kafkaesque::Consumer.new(config)
      t = consumer.send(:create_worker, 1)

      consumer.queue.put( :one )
      consumer.queue.put( :stop )
      t.join
      assert WorkerSameThread.should_be_true
    end
  end
end
