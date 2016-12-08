# Load Path
$:.unshift File.expand_path('..', __FILE__)

# Gems
require 'rubygems'
require 'bundler'
Bundler.require(:default)

# Boot
require 'config/boot.rb'

task :run do
  PoloniexTicker.run
end
