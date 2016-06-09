module Riemann
  module Metrics
    class NotificationsHandler

      attr_reader :client

      def initialize client
        @client = client
      end

      def total_time start, finish
        ( finish - start ) * 1000
      end

      """action is nil for mailer"""
      def report(metric_name, state, controller, action, metric)

        (full_metric_name, tags) = 
          if client.opentsdb_style
            [ metric_name, 
              {:controller => controller,
               :action => action
              }
            ]
          else
            action.nil? ?
              [ "#{controller}.#{metric_name}",
                [controller, metric_name]
              ]
              : 
              [ "#{controller}.#{action}.#{metric_name}",
                [controller, action, metric_name]
              ]
          end

        client.gauge(tags, state, metric, full_metric_name)

      end

      def get_state(payload)
        !payload[:exception].nil? ? Riemann::Metrics::Client::CRITICAL : Riemann::Metrics::Client::OK
      end

      def process_action_action_controller channel, start, finish, id, payload
        controller = payload[:controller]
        action = payload[:action]
        state = get_state(payload)
        report('http_status', state, controller, action, payload[:status])
        report('view_runtime', state, controller, action, payload[:view_runtime])
        report('request_runtime', state, controller, action, total_time(start, finish))
        report('db_runtime', state, controller, action, payload[:db_runtime])
      end

      def deliver_action_mailer channel, start, finish, id, payload
        tags = [ payload[:mailer] ]
        state = get_state(payload)
        report('email_send_runtime', state, payload[:mailer], nil, total_time(start, finish))
      end

    end

  end

end
