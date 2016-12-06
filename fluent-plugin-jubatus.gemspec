# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'fluent-plugin-jubatus'
  gem.version       = '0.0.2'
  gem.authors       = ['MATSUMOTO, Katsuyoshi']
  gem.email         = ['github@katsyoshi.com']
  gem.description   = %q{Jubatus output plugin for fluentd}
  gem.summary       = %q{Jubatus output plugin for fluentd}
  gem.homepage      = 'https://github.com/katsyoshi/fluent-plugin-jubatus'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'fluentd'
  gem.add_dependency 'jubatus', '~> 1.0.0'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'minitest'
end
