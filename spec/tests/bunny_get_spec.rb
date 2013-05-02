require 'spec_helper'
require 'support/test_tracker'

#require 'carrot'
require 'json'
require 'awesome_print'

require 'redis'


set :environment, :test

describe "Rabbit Tests" do
  include Rack::Test::Methods

  before(:all) do
    BunnyExchange.instance.start
    @redis = Redis.new
  end

  after (:all) do
    BunnyExchange.instance.close
  end

  it "should recieve messages using bunny" do
    BunnyExchange.instance.subscribe(APP_CONFIG['test_queue'])
    #::Timeout.timeout(480) do
      todo = 1
      while todo > 0 do
        sleep(0.01)
        message=BunnyExchange.instance.pop(APP_CONFIG['test_queue'])
        if message
          puts "Message #{ap message}"
          todo = @redis.get("workleft").to_i
          @redis.set("workleft", (todo-1).to_s)
        end

        puts "Work to do: #{todo}"
      end
    #end
    puts "done."
    true.should be_true
  end
end