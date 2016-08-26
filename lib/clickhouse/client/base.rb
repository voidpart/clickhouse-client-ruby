require 'clickhouse/query'

module Clickhouse::Client::Base
  def initialize(options)
    initialize_connection(options)
  end

  def query(raw_sql, options={})
    body = exec(raw_sql, options)
    CSV.parse(body, col_sep: '\t')
  end
  
  def build
    Clickhouse::Query.new(self)
  end
end
