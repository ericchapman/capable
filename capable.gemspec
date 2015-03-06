# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capable/version'

Gem::Specification.new do |spec|
  spec.name          = "capable"
  spec.version       = Capable::VERSION
  spec.authors       = ["Eric Chapman"]
  spec.email         = ["contact@ericjchapman.com"]
  spec.summary       = %q{GEM that wil allow 'roles' to be assigned to existing objects by creating 'abilities' and assigning them to objects as capabilities.}
  spec.description   = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec'
  if RUBY_VERSION < '1.9.3'
    spec.add_runtime_dependency('activerecord', '< 4.0.0')
  else
    spec.add_runtime_dependency('activerecord')
  end
  spec.add_development_dependency('mysql2')
  spec.add_development_dependency('pg')
  spec.add_development_dependency('sqlite3')
end
