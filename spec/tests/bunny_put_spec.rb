require 'spec_helper'
require 'support/test_tracker'

#require 'carrot'
require 'json'
require 'awesome_print'

require "redis"

set :environment, :test


describe "Rabbit Tests" do
  include Rack::Test::Methods

  before(:all) do
    @redis = Redis.new
    TestTracker.instance.reset
    BunnyExchange.instance.start
  end

  after (:all) do
    BunnyExchange.instance.close
  end

  def app
    Sinatra::Application
  end

  it "should sget /" do
    get '/'
    last_response.should be_ok
  end

  it "should send and recieve messages using bunny" do
    #::Timeout.timeout(480) do
    i=0
    (0..10).each do |j|
      @redis.set("workleft", "0")
      (0..50).each do |i|
        message={}
        message["uuid"] = SecureRandom.uuid.to_s
        message['ix'] = i
        puts "send message:#{i}"
        num = @redis.get("workleft").to_i
        num=0 if num.nil?
        @redis.set("workleft", (num+1).to_s)
        BunnyExchange.instance.publish(APP_CONFIG['test_queue'], message.to_json)
      end
      #end
      i+=1
      puts "waiting for 10 minutes: #{i}."
      sleep(60*10) # 600= ten miunutes.
    end
    puts "done."
    true.should be_true
  end
end