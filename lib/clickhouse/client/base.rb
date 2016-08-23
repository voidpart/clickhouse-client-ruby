module Clickhouse::Client::Base
  def initialize(options)
    initialize_connection(options)
  end

  def query(raw_sql, options={})
    params = {query: raw_sql}
    body = options[:body]
    
    template_data = options[:template_data]
    if template_data
      raise "Cannot specify body body and template_data" if body
      body = {}
      merge_template_data(body, params, template_data)
    end

    exec(params, body)
  end
  
  def build
    Clickhouse::Client::Query.new(self)
  end

  protected

  def merge_template_data(body, params, data)
    data.each do |key, value|
      next unless value[:io]

      body[key] = value[:io]

      format = value[:format]
      params["#{key}_format"] = format if format

      structure = value[:structure]
      params["#{key}_structure"] = structure if structure

      types = value[:types]
      params["#{key}_types"] = types if types
    end
  end
end
