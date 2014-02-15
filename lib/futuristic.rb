require File.expand_path(File.join(File.dirname(__FILE__), 'futuristic/version'))
require 'motion-require'
unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

Motion::Require.all(Dir.glob(File.expand_path('../futuristic/**/*.rb', __FILE__)))