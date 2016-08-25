require 'test_helper'

module Clickhouse
  class QueryTest < ::Minitest::Test
    def setup
      @client = Client.new(url: 'http://localhost:8123/')
      @query = @client.build
    end

    def test_execute
      q = @query.select('*').from('system.numbers').limit(2)
      assert_equal (0..1).to_a, q.execute.flatten.map(&:to_i)
      hash = [{one: '0'}, {one: '1'}]
      assert_equal hash, q.execute(:one)
    end

    def test_result
      q = @query.select('*').from('system.numbers').limit(2)
      assert q.result.is_a? Clickhouse::Client::Result
    end

    def test_from
      q = @query.select('*').from('system.numbers')
      assert_equal "SELECT * FROM numbers", q.from('numbers').to_sql
      assert_equal "SELECT * FROM system.numbers", q.to_sql
      subquery = @query.select('*')
      assert_equal "SELECT * FROM (SELECT *)", q.from(subquery).to_sql
    end

    def test_limit_offset
      q = @query.select('*').limit(10)
      assert_equal "SELECT * LIMIT 0, 5", q.limit(5).to_sql
      assert_equal "SELECT * LIMIT 0, 10", q.to_sql
      assert_equal "SELECT * LIMIT 10, 10", q.offset(10).to_sql
    end

    def test_select
      assert_equal "SELECT *", @query.select('*').to_sql
      q = @query.select('_1')
      assert_equal "SELECT _1, _2", q.select('_2').to_sql
      assert_equal "SELECT _1", q.to_sql
    end

    def test_where
      q = @query.select('*')
      assert_equal "SELECT * WHERE one = 1", q.where(one: 1).to_sql
      assert_equal "SELECT * WHERE one < 1", q.where('one < ?', 1).to_sql
      assert_equal "SELECT * WHERE one BETWEEN 1 AND 2", q.where(one: 1..2).to_sql
      assert_equal "SELECT * WHERE one in (1, 2)", q.where(one: (1..2).to_a).to_sql
      assert_equal "SELECT * WHERE one in (1, 2)", q.where('one in ?', (1..2).to_a).to_sql
      assert_equal "SELECT * WHERE one in (SELECT *)", q.where(one: q).to_sql
      assert_equal "SELECT * WHERE one in (SELECT *)", q.where('one in ?', q).to_sql
      q = q.where(one: 1)
      assert_equal "SELECT * WHERE one = 1 AND two = 2", q.where(two: 2).to_sql
      assert_equal "SELECT * WHERE one = 1 AND two >= 2", q.where('two >= ?', 2).to_sql
      assert_equal "SELECT * WHERE one = 1", q.to_sql
    end

    def test_group
      q = @query.select('*').group(:one)
      assert_equal "SELECT * GROUP BY one, two", q.group(:two).to_sql
      assert_equal "SELECT * GROUP BY one", q.to_sql
    end

    def test_order
      q = @query.select('*').order(:one)
      assert_equal "SELECT * ORDER BY one, two", q.order(:two).to_sql
      assert_equal "SELECT * ORDER BY one", q.to_sql
    end

    def test_having
      q = @query.select('*').group(:one)
      assert_equal "SELECT * GROUP BY one HAVING two = 2", q.having(two: 2).to_sql
      assert_equal "SELECT * GROUP BY one HAVING two < 2", q.having('two < ?', 2).to_sql
      assert_equal "SELECT * GROUP BY one HAVING two BETWEEN 1 AND 2", q.having(two: 1..2).to_sql
      q = q.having(two: 2)
      assert_equal "SELECT * GROUP BY one HAVING two = 2 AND three = 3", q.having(three: 3).to_sql
      assert_equal "SELECT * GROUP BY one HAVING two = 2 AND three >= 3", q.having('three >= ?', 3).to_sql
      assert_equal "SELECT * GROUP BY one HAVING two = 2", q.to_sql
    end
  end
end
