require 'riemann'

module Riemann
  module Metrics
    class Client

      OK        = "ok"
      CRITICAL  = "critical"
      WARNING   = "warning"
      STATES    = [OK,CRITICAL,WARNING]

      TTL = 10

      def initialize host, port, service_name, riemann_env, ttl, opentsdb_style
        @host = host
        @port = port
        @service_name = service_name
        @ttl = ttl || TTL
        @riemann_env = riemann_env || 'none'
        @hostname = get_hostname
        @opentsdb_style = opentsdb_style || false
      end

      def client
        @riemann_client ||= Riemann::Client.new(host: @host, port: @port)
      end

      def gauge tags, state, metric, service='', description=nil
        t = tags.is_a?(Hash) ? tags.map{|k,v|"#{k}=#{v}"} : tags
        the_tags = !@opentsdb_style ? (t.dup << @riemann_env) : (t.dup << "env=#{riemann_env}")
        event = {
          host: @hostname,
          state: state,
          metric: metric,
          ttl: @ttl,
          tags: the_tags,
          service: "#{@service_name}.#{service}"
        }
        event[:description] = description if description
        client << event
      end

      def report(service, metric, tags)

        gauge(t, OK, metric, service)
      end

      def get_hostname
        `hostname`.strip
      end

    end

  end

end
