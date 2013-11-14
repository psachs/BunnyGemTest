# encoding: utf-8

require 'bunny'
require 'json'

# Sample RabbitMQ Publisher
#
# @author Pascal Sachs <pascal.sachs@koubachi.com>
#
# @version 0.1
#
class Publisher
  def initialize
    @connection = Bunny.new
    @connection.start
    @channel = @connection.create_channel
    @exchange = Bunny::Exchange.new(@channel, :fanout, 'test-1234', {:durable => true})
  end

  def start
    message = File.new("request.json").read.to_s
    i = 0
    while true do
      message = {
        :timestamp => Time.now.to_f,
        :id => i,
        :message => "Hello World"
      }
      puts "Send message: number #{i}"
      @exchange.publish(message.to_json)
      i = i + 1
      sleep 0.01
    end
  end
end

publisher = Publisher.new
publisher.start
