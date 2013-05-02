#\ -s puma -p 5000
require 'sinatra_app.rb'

require 'rack/handler/puma'

# startup the server with puma:
use Rack::Handler::Puma

server_port = (ENV.nil? || ENV['HEROKU_PORT'].nil?) ? 5006 : ENV['HEROKU_PORT']

Rack::Handler::Puma.run (Rack::URLMap.new \
  "/"       => Sinatra::Application), :Port => 9292, :Host => "0.0.0.0"
