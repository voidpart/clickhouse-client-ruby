class Clickhouse::Client::Railtie < ::Rails::Railtie
  initializer 'clickhouse-client.config' do
    config = Rails.application.config_for(:clickhouse)

    Clickhouse.class_eval do
      cattr_accessor :client
    end

    Clickhouse.client = Clickhouse::Client.new(config.symbolize_keys)
  end

  initializer 'clickhouse-client.logger' do
    Clickhouse::Client.logger ||= Rails.logger
  end
end
