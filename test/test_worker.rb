require 'helper'

class TestWorker < Test::Unit::TestCase

  context "worker" do
    setup do
      @queue = java.util.concurrent.ArrayBlockingQueue.new(20)
    end

    should "stop when taking stop symbol from queue" do
      10.times { |i| @queue.put("aa 127.0.0.1 #{i} /k/call/") }
      @queue.put(:stop)

      handler = mock("handler")
      handler.expects(:handle).times(10)
      handler_class = mock("handler_class")
      handler_class.expects(:new).returns(handler)
      worker = Kafkaesque::Worker.new(@queue, :handler => handler_class)
      worker.do_work
    end

    should "create event and call handler" do
      @queue.put("aa 127.0.0.1 123 /k/call/")
      @queue.put(:stop)

      event = mock(event)
      Kafkaesque::Event.expects(:new).with("aa 127.0.0.1 123 /k/call/").returns(event)
      handler = mock("handler")
      handler.expects(:handle).with(event)
      handler_class = mock("handler_class")
      handler_class.expects(:new).returns(handler)
      worker = Kafkaesque::Worker.new(@queue, :handler => handler_class)
      worker.do_work
    end
  end

end

