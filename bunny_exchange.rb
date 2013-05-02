require 'bunny'
require 'json'
require 'singleton'

class BunnyExchange
  include Singleton
  attr_reader :channel, :exchange

  def initialize

  end

  def start
    info "*****BunnyExchange*****: connecting to exchange: #{APP_CONFIG['rabbitmq_server_url']}"

    begin
      @connection = Bunny.new(APP_CONFIG['rabbitmq_server_url'])
      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.default_exchange
      @queue = {}
    rescue Exception => e
      error "*****BunnyExchange*****: failed to connect to exchange: #{APP_CONFIG['rabbitmq_server_url']} #{e.message}  #{e.backtrace}"
      return
    end
  end

  def close
    return unless @connection
    @channel = nil; @exchange = nil
    @connection.stop; @connection = nil
  end

  def subscribe(key)
    @queue[key] = @channel.queue(key)
  end

  def publish(key, message)
    info "*****BUNNY***** Exchange: publishing to queue '#{key}' message: #{message}"
    @exchange.publish(message, {:key => key, :persistent => true})
  end

  def pop(key)
    delivery_info, metadata, payload = @queue[key].pop
    # convert hash keys to symbols
    params = JSON.parse(payload, {:symbolize_names => true}) if payload

    info "*****BUNNY***** Exchange: received on queue '#{key}' message: #{params}" if params

    return params
  end

  def info(message)
    puts "INFO :#{message}"
  end

  def error(message)
    puts "WARN :#{message}"
  end

  def error(message)
    puts "ERROR:#{message}"
  end
end

