require 'bunny'
require 'json'
require 'singleton'

class RabbitExchange
  include Singleton
  attr_reader :channel, :exchange

  def initialize
    info "RabbitExchange: connecting to exchange: #{APP_CONFIG['rabbitmq_server_url']}"

    begin
      @connection = Bunny.new(APP_CONFIG['rabbitmq_server_url'])
      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.default_exchange
      @exception_times=0
    rescue Exception => e
      error "RabbitExchange: failed to connect to exchange: #{APP_CONFIG['rabbitmq_server_url']} #{e.message}  #{e.backtrace}"
      return
    end
  end

  def close
    return unless @connection
    @channel = nil; @exchange = nil
    @connection.close; @connection = nil
  end

  def subscribe(queue, &block)
    if @exchange
      begin
        info "*****RABBIT***** Exchange: subscribing to queue '#{queue}'"
        @channel.queue(queue, :durable => true).subscribe do |delivery_info, metadata, payload|
          info "*****RABBIT***** Exchange: received on queue '#{queue}' message: #{payload}"
          params = JSON.parse(payload, {:symbolize_names => true})
          yield params
        end
        @exception_times = 0
        return true
      rescue Exception => e
        error "*****RABBIT***** Exception encountered during subscribed message handling on queue #{queue}. Message: '#{e.message}'"
        e.backtrace.each {|line| Rails.logger.error "#{line}"}
        warn "*****RABBIT***** Putting message back onto queue"
        @exception_times += 1
        @exchange.publish(queue,payload) if @exception_times < MAX_EXCEPTION_RETRIES
      end
    else # TODO: robustness when RabbitMQ not running
      error "*****RABBIT***** Exchange: exchange: #{APP_CONFIG['rabbitmq_server_url']} is not running. Ignoring queue subscribe to #{queue}"
      return false
    end
  end

  def publish(queue, message)
    message = message.to_s if message and !message.is_a? String
    if @exchange
      info "*****RABBIT***** Exchange: publishing to queue '#{queue}' message: #{message}"
      @exchange.publish(message, {:key => queue, :persistent => true})
      return true
    else # TODO: robustness when RabbitMQ not running
      error "*****RABBIT*****Exchange: exchange not running so ignoring publish to queue '#{queue}' message: #{message}"
      return false
    end
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

