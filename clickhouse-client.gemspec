# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'clickhouse/client/version'

Gem::Specification.new do |spec|
  spec.name          = "clickhouse-client"
  spec.version       = Clickhouse::Client::VERSION
  spec.authors       = ["Dmitry Kontsevoy"]
  spec.email         = ["dmitry.kontsevoy@gmail.com"]
  spec.homepage      = "https://github.com/h3xby/clickhouse-client-ruby"

  spec.summary       = %q{Simple client to Yandex Clickhouse datastore}
  spec.license       = "MIT"

  # spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files         = Dir["{bin,lib}/**/*"]
  spec.files        += ["LICENSE.txt", "Rakefile"]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday'
  spec.add_dependency "activesupport", ">= 4.0"
  spec.add_dependency 'net-http-persistent'

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
