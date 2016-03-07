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

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_dependency "railties", ">= 4.0"

  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "sqlite3", "~> 1.3"
  spec.add_development_dependency "mocha", "~> 1.0"
end
