module Kafkaesque
  class Worker

    def initialize(queue, config)
      @queue = queue
      @handler = config[:handler].new(config)
      @event_class = (config[:event] || Event)
    end

    def do_work
      loop do
        element = @queue.take
        if element == :stop
          @handler.cleanup if @handler.respond_to?(:cleanup)
          return
        end
        event = @event_class.new(element)
        begin
          @handler.handle(event)
        rescue
          p $!
          puts $!.backtrace
        end
      end
    end

  end
end

