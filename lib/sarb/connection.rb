module Sarb
  class Connection
    def initialize(app, ws)
      @app = app
      @ws = ws
    end

    def onopen(handshake)
      @app.trigger :connection_open, :connection => self
    end

    def onmessage(message)
      @app.invoke self, message
    end

    def onclose(event)
      @app.trigger :connection_close, :connection => self
    end

    def message(message)
      @ws.send(message.to_json)
    end

    def self.setup(app, ws)
      connection = Connection.new(app, ws)
      ws.onopen &connection.method(:onopen)
      ws.onmessage &connection.method(:onmessage)
      ws.onclose &connection.method(:onclose)
      connection
    end
  end
end

