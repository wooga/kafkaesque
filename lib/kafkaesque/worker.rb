module Kafkaesque
  class Worker

    def initialize(queue, config)
      @queue = queue
      @handler = config[:handler].new(config)
    end

    def do_work
      loop do
        element = @queue.take
        break if element == :stop
        event = Event.new(element)
        @handler.handle(event)
      end
    end

  end
end

