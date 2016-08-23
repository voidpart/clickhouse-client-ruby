# Clickhouse::Client

Simple client for Yandex Clickhouse.

Note: Right now this gem is not production-ready!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clickhouse-client', github: 'h3xby/clickhouse-client-ruby'
```

### Rails

Create config/clickhouse.yml and setup connection params to Clickhouse:

```YAML
development:
  url: http://127.0.0.1:8123
test:
  url: http://127.0.0.1:8123
production:
  url: <%= ENV['CLICKHOUSE_URL'] %>
```

After this you can access to client:

```ruby
Clickhouse.client
```

## Usage

This gem include simple query builder:

```ruby
Clickhouse.client.build
  .select('hit_id')
  .from('hits')
  .where(created_at: Date.today)
  .execute
```

It supports `where`, `from`, `select`, `group`, `having`, `join`, `limit`, `offset` operations.
