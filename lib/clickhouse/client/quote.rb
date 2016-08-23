module Clickhouse::Client::Quote
  def quote(value)
    _quote(value)
  end

  protected

  # Quotes a string, escaping any ' (single quote) and \ (backslash)
  # characters.
  def quote_string(s)
    s.gsub('\\'.freeze, '\&\&'.freeze).gsub("'".freeze, "''".freeze) # ' (for ruby-mode)
  end

  # Quote date/time values for use in SQL input. Includes microseconds
  # if the value is a Time responding to usec.
  def quoted_date(value)
    if value.acts_like?(:time)
      zone_conversion_method = ActiveRecord::Base.default_timezone == :utc ? :getutc : :getlocal

      if value.respond_to?(zone_conversion_method)
        value = value.send(zone_conversion_method)
      end
    end

    result = value.to_s(:db)
    if value.respond_to?(:usec) && value.usec > 0
      "#{result}.#{sprintf("%06d", value.usec)}"
    else
      result
    end
  end

  def quoted_true
    "'t'"
  end

  def unquoted_true
    't'
  end

  def quoted_false
    "'f'"
  end

  def unquoted_false
    'f'
  end

  def _quote(value)
    case value
    when String, ActiveSupport::Multibyte::Chars
      "'#{quote_string(value.to_s)}'"
    when true       then quoted_true
    when false      then quoted_false
      # BigDecimals need to be put in a non-normalized form and quoted.
    when BigDecimal then value.to_s('F')
    when Numeric, ActiveSupport::Duration then value.to_s
    when Date, Time then "'#{quoted_date(value)}'"
    when Symbol     then "'#{quote_string(value.to_s)}'"
    when Class      then "'#{value}'"
    else raise TypeError, "can't quote #{value.class.name}"
    end
  end
end
