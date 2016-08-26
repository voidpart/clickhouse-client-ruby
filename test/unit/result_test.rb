require 'test_helper'

module Clickhouse
  class ResultTest < ::Minitest::Test
    def setup
      @client = Client.new(url: 'http://localhost:8123/')
      @query = @client.build.select('*').from('system.numbers').limit(2)
      @result = @query.result
    end

    def test_to_a
      assert_equal [['0'], ['1']], @result.to_a
    end

    def test_to_h
      hash = [{number: '0'}, {number: '1'}]
      assert_equal hash, @result.to_h
    end

    def test_columns
      assert_equal %i(number), @result.columns
    end

    def test_count
      assert_equal 2, @result.count
    end

    def test_total_entries
      assert_equal 2, @result.total_entries
    end
  end
end
