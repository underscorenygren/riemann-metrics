require 'active_support/notifications'
require "riemann/metrics"

module Riemann
  module Metrics
    class Engine < Rails::Engine
      attr_reader :client, :handler

      config.riemann_metrics = ActiveSupport::OrderedOptions.new

      config.riemann_metrics.enabled = true
      config.riemann_metrics.host = 'localhost'
      config.riemann_metrics.port = 5555
      config.riemann_metrics.service_name = 'Rails'
      config.riemann_metrics.ttl = 5
      config.riemann_metrics.riemann_env = Rails.env
      config.riemann_metrics.opentsdb_style = false

      initializer "riemann_metrics.initialise" do |app|
        app_cfg = app.config.riemann_metrics
        Riemann::Metrics.initialize(app_cfg.host, app_cfg.port, app_cfg.service_name, app_cfg.riemann_env, app_cfg.ttl, app_cfg.opentsdb_style) if app_cfg.enabled
      end

      initializer "riemann_metrics.subscribe" do |app|
        ActiveSupport::Notifications.subscribe( /[^!]$/ ) do |*args|
          Riemann::Metrics.gauge args
        end
      end

    end

    def self.instrument channel, tags, state, metric, &block
      ActiveSupport::Notifications.instrument(channel, tags: tags, state: state, metric: metric) do
        block.call if block_given?
      end
    end

    def self.subscribe channel, &block
      ActiveSupport::Notifications.subscribe(channel) do |*args|
        block.call(@client, *args)
      end
    end

    def self.initialize(host, port, service_name, riemann_env, ttl, opentsdb_style)
      @client = Riemann::Metrics::Client.new(host, port, service_name, riemann_env, ttl, opentsdb_style)
      @handler = Riemann::Metrics::NotificationsHandler.new(@client)
    end

    def self.gauge args
      handler_method = args[0].gsub(".","_").to_sym
      @handler.send handler_method, *args if @handler.respond_to?(handler_method)
    end

  end
end
