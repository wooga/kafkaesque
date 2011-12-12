require 'helper'

class TestBookings < Test::Unit::TestCase
  context "calculate" do
    should "use the correct formula" do
      assert_equal 5.40, Kafkaesque::Bookings.calculate(100.0, 'de')
      assert_equal 5.40, Kafkaesque::Bookings.calculate(100.0, 'gb')
      assert_equal 7.0, Kafkaesque::Bookings.calculate(100.0, 'ch')
      assert_equal 7.0, Kafkaesque::Bookings.calculate(100.0, 'xx')
    end
  end
end