require 'active_support/core_ext/object/try'
require 'active_support/core_ext/module/attribute_accessors'

module Clickhouse
  class Client
    cattr_accessor :logger

    require 'clickhouse/client/base'
    require 'clickhouse/client/transport'
    require 'clickhouse/client/quote'
    require 'clickhouse/client/benchmark'

    include Base
    include Transport
    include Quote
    include Benchmark
  end
end

require 'clickhouse/client/railtie' if defined?(Rails)
