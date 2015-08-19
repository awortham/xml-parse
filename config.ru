require 'bundler'
Bundler.require

require "rack-timeout"
use Rack::Timeout          # Call as early as possible so rack-timeout runs before all other middleware.
Rack::Timeout.timeout = 40  # Recommended. If omitted, defaults to 15 seconds.

require './app'

run XmlApp
