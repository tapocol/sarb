require "spec_helper"

describe Sarb::Application do
  before do
    @app = Sarb::Application.new
  end

  context "initialize" do
    it "should set @actions @hooks @connections" do
      @app.instance_variable_get(:@actions).should == {}
      @app.instance_variable_get(:@hooks).should == {
        :connection_open => [@app.method(:connection_open)],
        :connection_close => [@app.method(:connection_close)]
      }
      @app.instance_variable_get(:@connections).should == Set.new
    end
  end

  context "action" do
    it "should add an action" do
      block = Proc.new {}
      @app.action :foo, &block
      expected = {:foo => block}
      @app.instance_variable_get(:@actions).should == expected
    end

    it "should add an action and convert name to sym" do
      block = Proc.new {}
      @app.action "foo", &block
      expected = {:foo => block}
      @app.instance_variable_get(:@actions).should == expected
    end
  end

  context "hook" do
    before do
      @app.instance_variable_set(:@hooks, {})
    end

    it "should add a new hook" do
      block = Proc.new {}
      @app.hook :foo, &block
      expected = {:foo => [block]}
      @app.instance_variable_get(:@hooks).should == expected
    end

    it "should add a new hook and convert name to sym" do
      block = Proc.new {}
      @app.hook "foo", &block
      expected = {:foo => [block]}
      @app.instance_variable_get(:@hooks).should == expected
    end

    it "should add a new hook to the existing hooks" do
      block1 = Proc.new { "block1" }
      @app.instance_variable_set(:@hooks, {:foo => [block1]})
      block2 = Proc.new { "block2" }
      @app.hook :foo, &block2
      expected = {:foo => [block1, block2]}
      @app.instance_variable_get(:@hooks).should == expected
    end
  end

  context "new_connection" do
    it "should pass along the websocket to the Connection and set onmessage event" do
      connection = Sarb::Connection.new(@app, "ws")
      Sarb::Connection.should_receive(:setup).with(@app, "ws").and_return(connection)
      @app.new_connection("ws").should === connection
    end
  end

  context "connection_open" do
    it "should add to @connections" do
      connection = "connection"
      @app.connection_open({:connection => connection})
      @app.instance_variable_get(:@connections).should == Set.new([connection])
    end
  end

  context "connection_close" do
    it "should remove from @connections" do
      connection1 = "connection1"
      connection2 = "connection2"
      @app.instance_variable_set(:@connections, Set.new([connection1, connection2]))
      @app.connection_close({:connection => connection1})
      @app.instance_variable_get(:@connections).should == Set.new([connection2])
    end
  end

  context "message_all" do
    it "should send message to all connections" do
      connection1 = Sarb::Connection.new(@app, "ws")
      connection2 = Sarb::Connection.new(@app, "ws")
      connection1.should_receive(:message).with("message")
      connection2.should_receive(:message).with("message")
      @app.instance_variable_set(:@connections, Set.new([connection1, connection2]))
      @app.message_all "message"
    end

    it "should allow exceptions to message_all" do
      connection1 = Sarb::Connection.new(@app, "ws")
      connection2 = Sarb::Connection.new(@app, "ws")
      connection1.should_receive(:message).with("message")
      connection2.should_not_receive(:message)
      @app.instance_variable_set(:@connections, Set.new([connection1, connection2]))
      @app.message_all "message", Set.new([connection2])
    end
  end

  context "run" do
    it "should start an EventMachine::WebSocket with defaults" do
      method = Proc.new {}
      method_expected = false
      @app.stub(:method).with(:new_connection).and_return(method)
      EventMachine::WebSocket.should_receive(:start){|&block| method_expected = (block == method)}.with(Sarb::Application::DEFAULTS)
      @app.run
      method_expected.should be_true
    end

    it "should start an EventMachine::WebSocket with given host and default port" do
      method = Proc.new {}
      method_expected = false
      @app.stub(:method).with(:new_connection).and_return(method)
      EventMachine::WebSocket.should_receive(:start){|&block| method_expected = (block == method)}.with(:host => "testhost", :port => Sarb::Application::DEFAULTS[:port])
      @app.run :host => "testhost"
      method_expected.should be_true
    end

    it "should start an EventMachine::WebSocket with default host and given port" do
      method = Proc.new {}
      method_expected = false
      @app.stub(:method).with(:new_connection).and_return(method)
      EventMachine::WebSocket.should_receive(:start){|&block| method_expected = (block == method)}.with(:host => Sarb::Application::DEFAULTS[:host], :port => "testport")
      @app.run :port => "testport"
      method_expected.should be_true
    end
  end

  context "invoke" do
    it "should call action's method" do
      @ws = "ws"
      connection = Sarb::Connection.new(@app, @ws)
      block = Proc.new {}
      @app.instance_variable_set(:@actions, {:action => block})
      JSON.should_receive(:parse).with("message").and_return({"action" => "action", "args" => {"foo" => "bar"}})
      block.should_receive(:call).with(connection, {"foo" => "bar"})
      @app.invoke(connection, "message")
    end
  end

  context "trigger" do
    it "should call all hooks' methods" do
      block1 = Proc.new { "block1" }
      block2 = Proc.new { "block2" }
      @app.instance_variable_set(:@hooks, {:foo => [block1, block2]})
      block1.should_receive(:call).with({:foo => :bar})
      block2.should_receive(:call).with({:foo => :bar})
      @app.trigger "foo", {:foo => :bar}
    end
  end
end

