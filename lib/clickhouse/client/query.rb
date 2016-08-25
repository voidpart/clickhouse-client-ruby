require 'clickhouse/client/quote'
require 'clickhouse/client/result'

class Clickhouse::Client::Query
  include Clickhouse::Client::Quote

  MULTIPLE_VALUES = %i(select where group having order)
  SINGLE_VALUES = %i(join from limit offset format)
  FROZEN_EMPTY_ARRAY = [].freeze

  MULTIPLE_VALUES.each do |name|
    class_eval <<-CODE, __FILE__, __LINE__+1
      def #{name}_values
        @values[:#{name}] || FROZEN_EMPTY_ARRAY
      end

      def #{name}_values=(values)
        @values[:#{name}] = values
      end
    CODE
  end

  SINGLE_VALUES.each do |name|
    class_eval <<-CODE, __FILE__, __LINE__+1
      def #{name}_value
        @values[:#{name}]
      end

      def #{name}_value=(value)
        @values[:#{name}] = value
      end
    CODE
  end

  class ConditionClause
    include Clickhouse::Client::Quote

    attr_accessor :args
    attr_accessor :query

    def initialize(query, *args)
      self.query = query
      self.args = args
    end

    def to_sql
      if query.is_a? Hash
        format_query_hash
      else
        replace_placeholders
      end
    end

    protected

    def format_query_hash
      query.map do |key, value|
        case value
        when Range then "#{key} BETWEEN #{quote(value.begin)} AND #{quote(value.end)}"
        when Clickhouse::Client::Query, Array then "#{key} in #{quote(value)}"
        else "#{key} = #{quote(value)}"
        end
      end.join(' AND ')
    end

    def replace_placeholders
      dup_args = args.clone
      query.gsub('?') do |m|
        _quote(dup_args.shift)
      end
    end

    def self.format_queries(arr)
      arr.map(&:to_sql).join(' AND ')
    end
  end

  attr_reader :client

  def initialize(client)
    @client = client
    @values = {}
    format!('JSONCompact')
  end

  def initialize_copy(other)
    @result = nil
    @values = Hash[@values]
  end

  (MULTIPLE_VALUES + SINGLE_VALUES).each do |method|
    define_method method do |*args|
      clone.send("#{method}!", *args)
    end
  end

  def execute(*args)
    rows = client.query(to_sql)
    if args.length == 0
      result.to_a
    else
      result.to_h(*args)
    end
  end

  def to_sql(type=nil)
    select_sql = select_values.join(', ') 
    sql = "SELECT #{ select_sql.present? ? select_sql : '*'}"
    sql << " FROM #{from_value}" if from_value

    sql << " #{join_value}" if join_value.present?

    where_sql = _where_sql
    sql << " WHERE #{where_sql}" if where_sql.present?

    group_sql = _group_sql
    sql << " GROUP BY #{group_sql}" if group_sql.present?

    having_sql = _having_sql
    sql << " HAVING #{having_sql}" if having_sql.present?

    order_sql = _order_sql
    sql << " ORDER BY #{order_sql}" if order_sql.present?

    limit_sql = _limit_sql
    sql << limit_sql if limit_sql.present?

    if type == :formatted
      format_sql = _format_sql
      sql << format_sql if format_sql.present?
    end

    sql
  end

  def format!(value)
    self.format_value = value
    self
  end

  def select!(*args)
    self.select_values += args
    self
  end

  def where!(query, *args)
    self.where_values += [ConditionClause.new(query, *args)]
    self
  end

  def group!(*args)
    self.group_values += args
    self
  end

  def join!(query)
    self.join_value = query
    self
  end

  def having!(query, *args)
    self.having_values += [ConditionClause.new(query, *args)]
    self
  end

  def from!(value)
    value = "(#{value.to_sql})" if value.is_a? Clickhouse::Client::Query
    self.from_value = value
    self
  end

  def limit!(value)
    self.limit_value = value
    self
  end

  def offset!(value)
    self.offset_value = value
    self
  end

  def order!(*args)
    self.order_values += args
    self
  end

  def result
    @result ||= Clickhouse::Client::Result.new(client.exec(to_sql(:formatted)), format: format_value)
  end

  protected

  def _format_sql
    " FORMAT #{format_value}"
  end

  def _order_sql
    order_values.join(', ')
  end

  def _limit_sql
    " LIMIT #{offset_value.to_i}, #{limit_value.to_i}" if limit_value
  end

  def _group_sql
    group_values.join(', ')
  end

  def _where_sql
    ConditionClause.format_queries(where_values)
  end

  def _having_sql
    ConditionClause.format_queries(having_values)
  end
end
