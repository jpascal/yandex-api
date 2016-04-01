# -*- encoding: utf-8 -*-
require File.expand_path('../lib/yandex-api/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Evgeniy Shurmin']
  gem.email         = ['eshurmin@gmail.com']
  gem.description   = %q{Yandex.API integration}
  gem.summary       = %q{Yandex.API integration}
  gem.homepage      = 'https://github.com/jpascal/yandex-api'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'yandex-api'
  gem.require_paths = ['lib']
  gem.version       = Yandex::API::VERSION

  gem.add_development_dependency 'bundler', '~> 1.7'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rubocop'
end
