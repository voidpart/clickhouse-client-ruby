require 'test_helper'

module Clickhouse
  class ClientTest < ::Minitest::Test
    def setup
      @client = Client.new(url: 'http://localhost:8123/')
    end

    def test_query
      result = @client.query('SELECT * FROM system.numbers limit 10').flatten.map(&:to_i)
      assert_equal (0..9).to_a, result

      assert_raises(Clickhouse::TransportError) { @client.query('SELECT') }
    end

    def test_build
      query = @client.build 
      assert query.is_a?(Clickhouse::Query)
      assert_equal @client, query.client
    end

    def test_quote
      assert_equal '1', @client.quote(1)
      assert_equal "'#{Date.today.to_s(:db)}'", @client.quote(Date.today)
      assert_equal "'#{Time.now.getutc.to_s(:db)}'", @client.quote(Time.now)
      assert_equal "'#{Time.now.getutc.to_s(:db)}'", @client.quote(Time.current)
      assert_equal "'\\\\'", @client.quote('\\')
      assert_raises { @client.quote(nil) }
    end

    def test_database
      @client = Client.new(url: 'http://localhost:8123/?database=system')
      result = @client.query('SELECT * FROM numbers limit 10').flatten.map(&:to_i)
      assert_equal (0..9).to_a, result
    end
  end
end
