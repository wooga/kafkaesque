require 'redis'
require 'kafka'

module Kafkaesque

  class Consumer

    STOP_REQUESTED = java.util.concurrent.atomic.AtomicBoolean.new(false)

    attr_reader :config, :queue

    def initialize(config)
      @config = config
      @queue = java.util.concurrent.ArrayBlockingQueue.new(config[:queue_size] || 10000)
    end

    def start
      @latch = java.util.concurrent.CountDownLatch.new(config[:kafka][:topics].size)
      threads = []
      number_of_workers.times do |i|
        threads << create_worker(i)
      end
      config[:kafka][:topics].each do |topic|
        threads << create_fetcher(topic)
      end
      threads << create_terminator
      puts "started consumer for handler: #{config[:handler]}"
      threads.each { |t| t.join }
    end

  private

    def create_worker(i)
      Thread.new do
        puts "started worker #{i}"
        Worker.new(queue, config).do_work
        puts "stopped worker #{i}"
      end
    end

    def create_fetcher(topic)
      fetcher = Fetcher.new(queue, topic, config)
      Thread.new do
        puts "started fetcher #{topic}"
        fetcher.do_fetch
        @latch.count_down
        puts "stopped fetcher #{topic}"
      end
    end

    def create_terminator
      Thread.new do
        puts "started terminator"
        @latch.await
        number_of_workers.times do
          @queue.put(:stop)
        end
        puts "stopped terminator"
      end
    end

    def number_of_workers
      config[:number_of_workers] || 10
    end

    def self.stop_requested?
      STOP_REQUESTED.get
    end

    def self.stop
      STOP_REQUESTED.set(true)
    end

  end
end



