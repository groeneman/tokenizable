require 'tokenizable'
require 'mongoid'

RSpec.configure do |config|
  config.color = true
  ENV['MONGOID_ENV'] = 'test'
  Mongoid.load!('spec/mongoid.yml')
end