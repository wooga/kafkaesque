require 'helper'

class TestEvent < Test::Unit::TestCase
  
  should "parse and split the incoming event correctly" do
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/ s=1234")
    assert_equal "mw", event.game
    assert_equal "212.87.32.10", event.ip
    assert_equal 1319457649, event.stamp
    assert_equal "/k/pgr/", event.uri
    assert_equal Hash[:s => "1234"], event.params
  end
  
  should "extract the call from the uri" do
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/ s=1234")
    assert_equal "pgr", event.call
  end
  
  should "overwrite ip with param w_ip if given" do
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/ w_ip=1538355497")
    assert_equal "91.177.113.41", event.ip
    assert_equal 1538355497, event.ip_numeric
  end
  
  should "should return numeric ip" do
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/")
    assert_equal 3562479626, event.ip_numeric
    assert_equal "212.87.32.10", event.ip
  end
  
  should "should return the timestamp" do
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/")
    assert_equal Time.at(1319457649), event.time
  end
  
  should "return city and country" do
    geoip = mock("geoip")
    Kafkaesque.stubs(:geoip).returns(geoip)
    geoip.expects(:country).with("212.87.32.10").once.returns(OpenStruct.new(:city_name => "Berlin", :country_code2 => "DE"))
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/")
    assert_equal "DE", event.country
    assert_equal "Berlin", event.city
  end
  
  should "cache nil returns from geoip" do
    geoip = mock("geoip")
    Kafkaesque.stubs(:geoip).returns(geoip)
    geoip.expects(:country).with("212.87.32.10").once.returns(nil)
    event = Kafkaesque::Event.new("mw 212.87.32.10 1319457649 /k/pgr/")
    assert_nil event.country
    assert_nil event.city
  end
  
  should "decode query string params" do
    assert_equal Hash.new, Kafkaesque::Event.parse(nil)
    assert_equal Hash[:bla => 'foo bar'], Kafkaesque::Event.parse("bla=foo%20bar")
    assert_equal Hash[:s => "122"], Kafkaesque::Event.parse("bla=&s=122")
    assert_equal Hash[:s => "122"], Kafkaesque::Event.parse("s=1234&s=122")
  end
  
end
