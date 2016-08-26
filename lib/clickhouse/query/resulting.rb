require 'csv'
require 'json'

module Clickhouse::Query::Resulting
  class Result
    attr_accessor :result_hash

    def initialize(body, options={})
      self.result_hash = parse(body, options)
    end

    def to_a
      result_hash[:rows]
    end

    def count
      result_hash[:count]
    end

    def total_entries
      result_hash[:total_entries]
    end

    def columns
      result_hash[:columns]
    end

    def to_h(*args)
      cols = args.present? ? args : self.columns
      raise "Specify columns or use different format" if cols.blank?

      to_a.map do |row|
        Hash[ cols.zip(row) ]
      end
    end

    protected

    def parse(body, options={})
      format = options[:format] || 'TabSeparated'
      case format
      when 'TabSeparated' then parse_tab_separated(body, options)
      when 'JSONCompact' then parse_json_compact(body, options)
      else raise 'Unknown format'
      end
    end

    def parse_json_compact(body, options)
      json = JSON.load(body)
      columns = json['meta'].map {|i| i['name']}
      {
        rows: json['data'],
        columns: columns.map(&:to_sym),
        count: json['rows'],
        total_entries: json['rows_before_limit_at_least']
      }
    end

    def parse_tab_separated(body, options)
      rows = CSV.parse(body, col_sep: '\t')

      {
        rows: rows
      }
    end
  end

  def initialize_copy(other)
    super

    @result = nil
  end

  def result
    @result ||= Result.new(client.exec(to_sql(:formatted)), format: format_value)
  end

  delegate :to_a, :to_h, to: :result

  def total_entries
    result.result_hash[:total_entries] ||= subquery_count
    result.total_entries 
  end

  def subquery_count
    client.build.from(self).select('count()').try(:to_a).try(:first).try(:first).to_i
  end
end
