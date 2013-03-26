# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'futuristic/version'

Gem::Specification.new do |gem|
  gem.name          = 'futuristic'
  gem.version       = Futuristic::VERSION
  gem.date          = '2013-03-21'
  gem.summary       = %q{Rubymotion Promise and Futures}
  gem.description   = %q{Rubymotion Promise and Futures helper on top of Grand Central Dispatch}
  gem.authors       = ["Mateus Armando"]
  gem.email         = 'seanlilmateus@yahoo.de'
  gem.files         = ["lib/futuristic.rb"]
  gem.homepage      = 'http://github.com/seanlilmateus/futuristic'
  
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end