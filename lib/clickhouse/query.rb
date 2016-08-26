class Clickhouse::Query
  require 'clickhouse/query/base'
  require 'clickhouse/query/quering'
  require 'clickhouse/query/resulting'

  include Base
  include Quering
  include Resulting

  def execute(*args)
    rows = client.query(to_sql)
    if args.length == 0
      result.to_a
    else
      result.to_h(*args)
    end
  end
end

if defined?(WillPaginate)
  require 'clickhouse/query/will_paginate' 
  Clickhouse::Query.include Clickhouse::Query::WillPaginate
end
