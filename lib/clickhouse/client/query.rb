class Clickhouse::Client::Query
  MULTIPLE_VALUES = %i(select where group having order)
  SINGLE_VALUES = %i(join from limit offset)

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

  attr_reader :client

  def initialize(client)
    @client = client
    @values = {}
  end

  def initialize_copy(other)
    @values = Hash[@values]
  end

  (MULTIPLE_VALUES + SINGLE_VALUES).each do |method|
    define_method method do |*args|
      clone.send("_#{method}", *args)
    end
  end

  def execute(*args)
    rows = client.query(to_sql)
    if args.length == 0
      rows
    else
      rows.map do |row|
        Hash[ args.zip(row) ]
      end
    end
  end

  def to_sql
    select_sql = select_values.join(', ') 
    sql = "SELECT #{ select_sql.present? ? select_sql : '*'}"
    sql << " FROM #{from_value}"

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

    sql
  end

  protected

  def _order_sql
    order_values.join(', ')
  end

  def _order(*args)
    self.order_values += args
    self
  end

  def _from(value)
    self.from_value = value
    self
  end

  def _limit(value)
    self.limit_value = value
    self
  end

  def _offset(value)
    self.offset_value = value
    self
  end

  def _limit_sql
    " LIMIT #{offset_value.to_i}, #{limit_value.to_i}" if limit_value
  end

  def _group_sql
    group_values.join(', ')
  end

  def _where_sql
    _replace_placeholders(where_values)
  end

  def _having_sql
    _replace_placeholders(having_values)
  end

  def _replace_placeholders(values)
    values.flat_map do |query, args|
      if query.is_a?(Hash)
        query.map do |key, value|
          case value
          when Range then "#{key} BETWEEN #{_quote(value.begin)} AND #{_quote(value.end)}"
          else "#{key} = #{_quote(value)}"
          end
        end
      else
        dup_args = args.clone
        query.gsub('?') do |m|
          _quote(dup_args.shift)
        end
      end
    end.join(' AND ')
  end

  def _quote(value)
    client.quote(value)
  end

  def _select(*args)
    self.select_values += args
    self
  end

  def _where(query, *args)
    self.where_values += [[query, args]]
    self
  end

  def _group(*args)
    self.group_values += args
    self
  end

  def _join(query)
    self.join_value = query
    self
  end

  def _having(query, *args)
    self.having_values += [[query, args]]
    self
  end
end
