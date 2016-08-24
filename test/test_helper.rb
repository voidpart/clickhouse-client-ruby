ENV["RAILS_ENV"] = "test"

require 'minitest/autorun'
require 'clickhouse-client'
require 'active_support/logger'
Clickhouse::Client.logger = ActiveSupport::Logger.new(STDOUT)
