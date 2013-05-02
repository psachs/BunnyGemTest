require 'carrot'
require 'json'
require 'singleton'

class RabbitExchange
  include Singleton
  attr_reader :channel, :exchange

  def initialize

  end

  def start
    info "*****CarrotExchange*****: using exchange: #{APP_CONFIG['rabbitmq_server_url']}"
    @queue = {}
  end

  def close
    Carrot.stop
  end

  def available
    return true
  end


  def subscribe(key)
    @queue[key] = Carrot.queue(key)
  end

  def publish(key, message)
    info "*****CARROT***** Exchange: publishing to queue '#{key}' message: #{message}"
    @queue[key] = Carrot.queue(key) if @queue[key].nil?
    @queue[key].publish(message)
  end

  def pop(key)
    payload = @queue[key].pop(:ack => true)
    # convert hash keys to symbols
    info "*****CARROT***** Exchange: received on queue '#{key}' payload: #{payload}" if payload

   # @queue[key].ack
    return payload
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

