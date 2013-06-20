# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safe_credentials/version'

Gem::Specification.new do |spec|
  spec.name          = "safe_credentials"
  spec.version       = SafeCredentials::VERSION
  spec.authors       = ["Alberto F. Capel"]
  spec.email         = ["afcapel@gmail.com"]
  spec.description   = %q{Encrypt sensitive credentials so you can store your configuration files in source control}
  spec.summary       = %q{Safe Credentials allows you to encrypt sensitive credentials so you can
store your configuration files in source control.}
  spec.homepage      = "https://github.com/afcapel/safe_credentials"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor"
  spec.add_dependency "gibberish"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
