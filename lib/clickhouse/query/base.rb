module Clickhouse::Query::Base
  attr_reader :client

  def initialize(client)
    @client = client
    @values = {}
    format!('JSONCompact')
  end
end
