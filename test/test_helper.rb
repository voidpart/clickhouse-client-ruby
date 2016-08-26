ENV["RAILS_ENV"] = "test"

require 'rubygems'
require 'bundler'

Bundler.require :default, :development

require 'minitest/autorun'
require 'active_support/logger'
Clickhouse::Client.logger = ActiveSupport::Logger.new(STDOUT)
