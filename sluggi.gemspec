# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sluggi/version'

Gem::Specification.new do |spec|
  spec.name          = "sluggi"
  spec.version       = Sluggi::VERSION
  spec.authors       = ["Tee Parham"]
  spec.email         = ["tee@neighborland.com"]
  spec.summary       = %q{Rails Slug Generator}
  spec.description   = %q{A Rails slug generator inspired by friendly_id}
  spec.homepage      = "https://github.com/neighborland/sluggi"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activerecord", "~> 4.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.1"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "rails", "~> 4.0"
end
