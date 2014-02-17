# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'futuristic/version'

Gem::Specification.new do |s|
  s.name          = 'futuristic'
  s.version       = Futuristic::VERSION
  s.date          = '2014-02-15'
  s.summary       = 'A Collection of RubyMotion Concurrency Helpers'
  s.description   = 'RubyMotion Concurrency Helpers such as Promise, Future and Atomic'
  s.authors       = ['Mateus Armando']
  s.email         = 'seanlilmateus@yahoo.de'

  s.files         = ['lib/futuristic.rb']
  s.homepage      = 'http://github.com/seanlilmateus/futuristic'
  s.license       = 'MIT'
  s.files         = `git ls-files`.split($\)
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_runtime_dependency 'motion-require', '~> 0.0', '>= 0.0.6'
  s.add_development_dependency 'rake', '~> 0'
end