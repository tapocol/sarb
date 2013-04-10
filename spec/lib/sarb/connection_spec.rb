require "spec_helper"

describe Sarb::Connection do
  before do
    @app = Sarb::Application.new
    @ws = EventMachine::WebSocket::Connection.new("asdf1234", {})
    @connection = Sarb::Connection.new(@app, @ws)
  end

  context "initialize" do
    it "should set app and ws" do
      @connection.instance_variable_get(:@app).should === @app
      @connection.instance_variable_get(:@ws).should === @ws
    end
  end

  context "onopen" do
    before do
      @handshake = EventMachine::WebSocket::Handshake.new("asdf1234")
    end

    it "should trigger app :connection_open" do
      @app.should_receive(:trigger).with(:connection_open, {:connection => @connection})
      @connection.onopen(@handshake)
    end
  end

  context "onmessage" do
    it "should use the app's handler" do
      @app.should_receive(:invoke).with(@connection, "message")
      @connection.onmessage("message")
    end
  end

  context "onclose" do
    it "should trigger app :connection_close" do
      @app.should_receive(:trigger).with(:connection_close, {:connection => @connection})
      @connection.onclose({})
    end
  end

  context "message" do
    it "should send through ws" do
      message = "message"
      message.should_receive(:to_json).and_return("message_str")
      @ws.should_receive(:send).with("message_str")
      @connection.message(message)
    end
  end

  context "setup" do
    it "should create new Connection and add 'on' events" do
      Sarb::Connection.should_receive(:new).with(@app, @ws).and_return(@connection)
      # TODO: Putting the intended blocks in the 'with' method on the following stubs causes an error.
      @ws.should_receive(:onopen)
      @ws.should_receive(:onmessage)
      @ws.should_receive(:onclose)
      Sarb::Connection.setup(@app, @ws)
    end
  end
end

