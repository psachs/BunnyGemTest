require 'rubygems'
require 'sinatra'

require 'rspec'
require 'test/unit'
require 'rack/test'


APP_CONFIG={}
APP_CONFIG['rabbitmq_server_url'] = 'amqp://localhost'
APP_CONFIG['test_queue'] = 'rabbit_test'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Pathname.new(File.dirname(File.dirname(__FILE__))).join("*.rb")].each { |t| require t }


RSpec.configure do |config|
  config.mock_with :rspec
end