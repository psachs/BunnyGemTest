
$:.unshift File.dirname(__FILE__)

require 'json'
require 'rufus/scheduler'
require 'awesome_print'
require 'benchmark'
require 'singleton'
require 'securerandom'

require 'bunny_exchange'

APP_CONFIG={}
APP_CONFIG['rabbitmq_server_url'] = 'amqp://localhost'
APP_CONFIG['test_queue_recv'] = 'rabbit_test2'
APP_CONFIG['test_queue_send'] = 'rabbit_test1'

class TestPoller2
  include Singleton
  attr_reader :channel, :exchange, :is_running, :is_checking

  def initialize

  end

  def self.clear_db_connections
    #ActiveRecord::Base.connection.close #unless ActiveRecord::Base.connection.nil?
    #ActiveRecord::Base.clear_active_connections!
    #ActiveRecord::Base.connection_pool.clear_stale_cached_connections!
  end

  def start
    return if @is_running
    @is_running = true

    BunnyExchange.instance.start
    BunnyExchange.instance.subscribe(APP_CONFIG['test_queue_recv'])

    unless BunnyExchange.instance.channel
      # TODO: handle missing
      error "ERROR: RabbitMQ not available"
      return
    end
    info "TestPoller: polling exchange: #{APP_CONFIG['rabbitmq_server_url']}"
    @scheduler = Rufus::Scheduler.start_new
    @is_running = false
    @is_checking = false

    @recognition_batcher = @scheduler.every '0.1s' do
      TestPoller2.safely do
        _handle_message(BunnyExchange.instance.pop(APP_CONFIG['test_queue_recv']))
      end
    end
  end

  # mae sure connections are opened and closed correctly: https://github.com/jmettraux/rufus-scheduler/issues/14
  def self.safely
    begin
      #ActiveRecord::Base.connection.verify!(0) unless ActiveRecord::Base.connected?
      yield
    rescue => e
      error e.inspect
    ensure
      begin
        TestPoller2.clear_db_connections
      rescue => e
        info("Scheduler error: #{e.message} \n#{e.backtrace}")
      end
    end
  end

  def _handle_message(params)
    if params
      info params
    end
  end

  def info(message)
    puts message
  end
  def error(message)
    puts message
  end
  def warn(message)
    puts message
  end
  def debug(message)
    puts message
  end
end

TestPoller2.instance.start

i=1
while (1) do
  sleep(0.1)
  puts "alive:#{i}"
  message={}
  message["uuid"] = SecureRandom.uuid.to_s
  message['ix'] = i
  puts "send message:#{i}"
  BunnyExchange.instance.publish(APP_CONFIG['test_queue_send'], message.to_json)
  if i%1000 == 0
    sleep(600)
  end

  i+=1
end