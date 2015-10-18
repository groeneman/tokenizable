# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tokenizable/version'

Gem::Specification.new do |spec|
  spec.name          = "tokenizable"
  spec.version       = Tokenizable::VERSION
  spec.authors       = ["Michael Groeneman"]
  spec.email         = ["michael@scripted.com"]
  spec.description   = %q{A little gem for creating nice tokens for Mongoid documents}
  spec.summary       = %q{A better summary goes here}
  spec.homepage      = "http://"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'mongoid', '~> 5.0.0'
  spec.add_dependency 'activesupport'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
