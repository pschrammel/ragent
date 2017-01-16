# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ragent/version'

Gem::Specification.new do |spec|
  spec.name          = "ragent"
  spec.version       = Ragent::VERSION
  spec.authors       = ["Peter Schrammel"]
  spec.email         = ["peter.schrammel@gmx.de"]

  spec.summary       = %q{An agent framework}
  spec.description   = %q{Writing of agents for monitoring, chatting, ...  should be easy. Ragent eases this with a small extraction layer over celluloid.}
  spec.homepage      = "https://github.com/pschrammel/ragent"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'celluloid', '~>0.17.0'
#  spec.add_dependency 'activesupport'
#  spec.add_dependency 'eventmachine'
#  spec.add_dependency 'faye-websocket'
  spec.add_dependency 'logging', '~>2.1'
#  spec.add_dependency 'celluloid-io' #needed for a plugin, should be removed

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
