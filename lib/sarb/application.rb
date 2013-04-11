module Sarb
  class Application
    DEFAULTS = {
      :host => "127.0.0.1",
      :port => 8080
    }

    def initialize
      @actions = {}
      @hooks = {
        :connection_open => [method(:connection_open)],
        :connection_close => [method(:connection_close)]
      }
      @connections = Set.new
    end

    def action(name, &block)
      @actions[name.to_sym] = block
    end

    def hook(name, &block)
      @hooks[name.to_sym] = [] unless @hooks.has_key?(name.to_sym)
      @hooks[name.to_sym] << block
    end

    def new_connection(ws)
      Connection.setup(self, ws)
    end

    def connection_open(args)
      @connections << args[:connection]
    end

    def connection_close(args)
      @connections.delete(args[:connection])
    end

    def message_all(message, exceptions=Set.new)
      @connections.each { |c| c.message(message) unless exceptions.include?(c) }
    end

    def run(options = {})
      EventMachine::WebSocket.start(DEFAULTS.merge(options), &method(:new_connection))
    end

    def invoke(connection, message)
      data = JSON.parse(message)
      @actions[data["action"].to_sym].call(connection, data["args"])
    end

    def trigger(name, args)
      @hooks[name.to_sym].each { |block| block.call(args) }
    end
  end
end

