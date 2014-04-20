require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

$:.unshift File.expand_path(File.join(__dir__, '..', 'lib'))
require 'fluent/test'
require 'fluent/plugin/out_jubatus'
require 'fluent/plugin/jubatus'
