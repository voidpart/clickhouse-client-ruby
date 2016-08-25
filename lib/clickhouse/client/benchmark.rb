module Clickhouse::Client::Benchmark
  def exec(raw_sql, options={})
    start = Time.now
    result = super
    stop = Time.now

    runtime = stop - start
    logger.info "[#{raw_sql[0..256]}] #{(runtime * 1000)} ms"

    result
  end

  protected

  def logger
    self.class.logger
  end
end
