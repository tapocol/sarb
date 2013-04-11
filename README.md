# Socket Action Ruby (sarb)

Framework for em-websocket that uses actions and triggers for real-time communication with your app.

## Install

For latest rubygems version:

```ruby
gem "sarb"
```

For latest github commit:

```ruby
gem "sarb", :git => "https://github.com/craigjackson/sarb.git"
```

## Example

```ruby
require "sarb"

app = Sarb::Application.new
app.action(:foo) { |session, args| session.message(:action => :bar) }
app.run
```

On client side:

```javascript
var ws = new WebSocket("ws://127.0.0.1:8080/");
ws.onmessage = function(message) { console.log(message) };
ws.send(JSON.stringify({ action: "foo" }))
```

### Linked Examples

- [Chat App](https://github.com/craigjackson/sarb-chat)

## License

The MIT License - Copyright (c) 2012-2013 Craig Jackson

