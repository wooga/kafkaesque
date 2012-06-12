# Kafkaesque

A JRuby-based event stream processing framework for Kafka.

## Example

```ruby
Kafkaesque::Consumer.new(
  :handler => MyHandler,
  :event => MyEvent,
  :number_of_workers => 5,
  :kafka => {
    :host => '192.168.0.1',
    :topics => %w[foo bar]
  }
).start
```

## Contributing to Kafkaesque

* fork the project
* start a feature branch
* make sure to add tests
* please try not to mess with the Rakefile, version, or history

## Copyright

Copyright (c) 2011, 2012 Wooga GmbH, Berlin