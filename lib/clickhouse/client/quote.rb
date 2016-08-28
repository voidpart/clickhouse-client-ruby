require 'active_support/multibyte/chars'
require 'active_support/duration'
require 'active_support/core_ext/time' # For to_s(:db) support

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
      if value.respond_to?(:getutc)
        value = value.getutc
      end
    end

    result = value.to_s(:db)
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
    when Array then "(#{value.map{|i| quote(i)}.join(', ')})"
    when Clickhouse::Query then "(#{value.to_sql})"
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
    else raise "can't quote #{value.class.name}"
    end
  end
end
