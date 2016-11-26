# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "middleman/caching_proxy/version"

Gem::Specification.new do |spec|
  spec.name          = "middleman-caching-proxy"
  spec.version       = Middleman::CachingProxy::VERSION
  spec.authors       = ["Joe Yates"]
  spec.email         = ["joe.g.yates@gmail.com"]

  spec.summary       = %q{Speed up Middleman builds via a cache}
  spec.description   = %q{Keeps a cache of proxy pages and uses the cached copy if the proxied object hasn't changed}
  spec.homepage      = "https://github.com/joeyates/middleman-caching-proxy"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "middleman", ">= 3.0.0", "< 4.0.0"
  spec.add_runtime_dependency "semantic"
  spec.add_runtime_dependency "autostruct"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
