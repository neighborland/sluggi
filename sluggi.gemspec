# frozen_string_literal: true

require "./lib/sluggi/version"

Gem::Specification.new do |spec|
  spec.name          = "sluggi"
  spec.version       = Sluggi::VERSION
  spec.authors       = ["Tee Parham"]
  spec.email         = ["tee@neighborland.com"]
  spec.summary       = "Rails Slug Generator"
  spec.description   = "A Rails slug generator inspired by friendly_id"
  spec.homepage      = "https://github.com/neighborland/sluggi"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "activerecord", "~> 6.0"
  spec.add_dependency "railties", "~> 6.0"
end
