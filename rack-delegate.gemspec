lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rack/delegate/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-delegate"
  spec.version       = Rack::Delegate::VERSION
  spec.authors       = ["Genadi Samokovarov"]
  spec.email         = ["gsamokovarov@gmail.com"]

  spec.summary       = "Rack level reverse proxy."
  spec.description   = "Rack level reverse proxy."
  spec.homepage      = "https://github.com/gsamokovarov/rack-delegate"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rack"
  spec.add_dependency "timeout_errors"
end
