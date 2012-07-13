require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'kafkaesque'

class Test::Unit::TestCase
  # Capture stdout and stderr. Go for puts from exceptions when they're actually
  # caught.
  def silence_is_golden
    old_stderr,old_stdout,stdout,stderr = $stderr,$stdout,StringIO.new,
                                          StringIO.new
    $stdout = stdout
    $stderr = stderr
    result = yield
    [result, stdout.string, stderr.string]
  ensure
    $stderr, $stdout = old_stderr, old_stdout
  end
end
