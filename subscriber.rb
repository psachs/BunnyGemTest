# encoding: utf-8

require 'bunny'
require 'json'

# Sample RabbitMQ Subscriber
#
# @author Pascal Sachs <pascal.sachs@koubachi.com>
#
# @version 0.1
#
class Subscriber
  def initialize
    @connection = Bunny.new
    @connection.start
    @channel = @connection.create_channel
    @exchange = Bunny::Exchange.new(@channel, :fanout, 'test-1234', {:durable => true})
    @queue = @channel.queue("test-queue-1234").bind("test-1234")
  end

  def start
    i = 0

    @threads = []
    @threads << Thread.new do
      @queue.subscribe(:block => true, :ack => true) do |delivery_info, properties, payload|
        message = JSON.parse(payload)
        puts "#{Time.now.to_f - message['timestamp'].to_f}" unless message.nil?
        @channel.basic_ack(delivery_info.delivery_tag, false)
      end
    end

    @threads.each do |thread|
      thread.join
    end

  end
end

subscriber = Subscriber.new
subscriber.start
