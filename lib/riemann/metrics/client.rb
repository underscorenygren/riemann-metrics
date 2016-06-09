require 'riemann'

module Riemann
  module Metrics
    class Client

      attr_reader :opentsdb_style
      attr_writer :opentsdb_style

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
        @riemann_client ||= Riemann::Client.new(host: @host, port: @port, opentsdb_style: @opentsdb_style)
      end

      def gauge tags, state, metric, service='', description=nil
        the_tags = 
          if tags.is_a?(Hash) 
            {env: @riemann_env}.merge(tags).map{|k,v|"#{k}=#{v}"} 
          else
            tags.dup << @riemann_env 
          end
        event = {
          host: @hostname,
          state: state,
          metric: metric,
          ttl: @ttl,
          tags: the_tags,
          service: "#{@service_name}.#{service}"
        }
        event[:description] = description if description
        add_event(event)
      end

      #Separate function so we can stub it out
      def add_event(event)
        client << event
      end

      def report(service, metric, tags)

        gauge(tags, OK, metric, service)
      end

      def get_hostname
        `hostname`.strip
      end

    end

  end

end
