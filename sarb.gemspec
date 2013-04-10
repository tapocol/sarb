Gem::Specification.new do |s|
  s.name        = "sarb"
  s.version     = "0.1.0"
  s.summary     = "Socket Action Ruby"
  s.description = "Framework for em-websocket that uses actions and triggers for real-time communication with your app."
  s.authors     = ["Craig Jackson"]
  s.email       = "tapocol@gmail.com"
  s.homepage    = "https://github.com/craigjackson/sarb"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency("em-websocket", ">= 0.5.0")
end

