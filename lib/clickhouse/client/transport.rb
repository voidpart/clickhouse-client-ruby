module Clickhouse::Client::Transport
  def initialize_connection(options={})
    url = options[:url]
    @conn = Faraday.new(url: url) do |faraday|
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.adapter Faraday.default_adapter
    end
  end

  def exec(params, body=nil)
    resp = conn.post do |req|
      req.params = params
      req.body = body
    end
    raise Clickhouse::TransportError.new(resp.body) if resp.status != 200
    CSV.parse(resp.body, col_sep: "\t")
  end

  protected

  attr_reader :conn
end
