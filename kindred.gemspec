# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kindred-rails/version'

Gem::Specification.new do |spec|
  spec.name          = "kindred-rails"
  spec.version       = Kindred::Rails::VERSION
  spec.authors       = ["Mike Piccolo"]
  spec.email         = ["mpiccolo@newleaders.com"]
  spec.summary       = %q{}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     "rails",          ">= 3.0"
  spec.add_runtime_dependency     "happy_place",    ">= 0.0.6"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
