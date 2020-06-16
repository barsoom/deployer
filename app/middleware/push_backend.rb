require "faye/websocket"
require "redis"
require "thread"

Faye::WebSocket.load_adapter("puma")

class PushBackend
  CHANNEL        = "push"

  def self.push(data)
    # No redis in test env for now
    # Push isn't strictly needed to use the app anyhow and hard to test.
    return if Rails.env.test?

    @@publisher.publish(CHANNEL, data.to_json)
  end

  def initialize(app)
    @app = app
    @clients = []
    @@publisher = @publisher = build_redis

    subscribe_and_push
    keep_connection_open
  end

  def call(env)
    if Faye::WebSocket.websocket?(env) && authorized?(env)
      ws = Faye::WebSocket.new(env)
      ws.on :open do |event|
        clients << ws
      end

      ws.on :close do |event|
        clients.delete(ws)
        ws = nil
      end

      ws.rack_response
    else
      app.call(env)
    end
  end

  private

  attr_reader :publisher, :clients, :app

  def authorized?(env)
    request = ActionDispatch::Request.new(env)
    request.session[:logged_in]
  end

  def subscribe_and_push
    Thread.new do
      subscriber = build_redis
      subscriber.subscribe(CHANNEL) do |on|
        on.message do |channel, message|
          push(message)
        end
      end
    end
  end

  def keep_connection_open
    Thread.new do
      loop do
        sleep 5
        push("ping")
      end
    end
  end

  def push(message)
    clients.each { |ws| ws.send(message) }
  end

  def build_redis
    port = ENV["DEVBOX"] ? `service_port redis`.chomp : 6379
    uri = URI.parse(ENV["REDISCLOUD_URL"] || "redis://localhost:#{port}")
    Redis.new(host: uri.host, port: uri.port, password: uri.password)
  end
end
