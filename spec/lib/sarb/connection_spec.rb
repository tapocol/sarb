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

      onopen_expected = false
      onopen_method = Proc.new{ :onopen }
      @connection.should_receive(:method).with(:onopen).and_return(onopen_method)
      @ws.should_receive(:onopen) { |&block| onopen_expected = (block == onopen_method) }

      onmessage_expected = false
      onmessage_method = Proc.new{ :onmessage }
      @connection.should_receive(:method).with(:onmessage).and_return(onmessage_method)
      @ws.should_receive(:onmessage) { |&block| onmessage_expected = (block == onmessage_method) }

      onclose_expected = false
      onclose_method = Proc.new{ :onclose }
      @connection.should_receive(:method).with(:onclose).and_return(onclose_method)
      @ws.should_receive(:onclose) { |&block| onclose_expected = (block == onclose_method) }

      Sarb::Connection.setup(@app, @ws).should be_equal(@connection)
      onopen_expected.should be_true
      onmessage_expected.should be_true
      onclose_expected.should be_true
    end
  end
end

