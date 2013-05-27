# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluent-plugin-jubatus/version'

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-jubatus"
  gem.version       = Fluent::Plugin::Jubatus::VERSION
  gem.authors       = ["MATSUMOTO Katsuyoshi"]
  gem.email         = ["matsumoto.katsuyoshi+github@gmail.com"]
  gem.description   = %q{TODO hoge}
  gem.summary       = %q{TODO hoge}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'fluentd'
  gem.add_dependency 'jubatus'
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rake"
end
