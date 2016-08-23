module Clickhouse::Client::Benchmark
  def exec(params, body=nil)
    query = params.try(:[], :query)

    start = Time.now
    result = super
    stop = Time.now

    runtime = stop - start
    logger.info "[#{query.truncate(256)}] #{(runtime * 1000)} ms"

    result
  end
end
