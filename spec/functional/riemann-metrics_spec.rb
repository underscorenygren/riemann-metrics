require 'spec_helper'

describe AwesomeController, :type => :controller do

  context 'given a rails application' do

    it 'should collect metrics for process_action_action_controller' do
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "index", "http_status"],
        "ok",
        200,
        "AwesomeController.index.http_status"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "index", "view_runtime"],
        "ok",
        anything(),
        "AwesomeController.index.view_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "index", "request_runtime"],
        "ok",
        anything(),
        "AwesomeController.index.request_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "index", "db_runtime"],
        "ok",
        nil,
        "AwesomeController.index.db_runtime"
      )

      get 'index'
    end

    it 'should collect metrics for deliver_action_mailer' do
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "send_email", "http_status"],
        "ok",
        200,
        "AwesomeController.send_email.http_status"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "send_email", "view_runtime"],
        "ok",
        anything(),
        "AwesomeController.send_email.view_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "send_email", "db_runtime"],
        "ok",
        anything(),
        "AwesomeController.send_email.db_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "send_email", "request_runtime"],
        "ok",
        anything(),
        "AwesomeController.send_email.request_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeMailer", "email_send_runtime"],
        "ok",
        anything(),
        "AwesomeMailer.email_send_runtime"
      ).at_least(:once)

      get 'send_email'
    end

    it 'should allow for custom metric collection' do
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "custom_metrics", "http_status"],
        "ok",
        200,
        "AwesomeController.custom_metrics.http_status"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "custom_metrics", "view_runtime"],
        "ok",
        anything(),
        "AwesomeController.custom_metrics.view_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "custom_metrics", "db_runtime"],
        "ok",
        anything(),
        "AwesomeController.custom_metrics.db_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["AwesomeController", "custom_metrics", "request_runtime"],
        "ok",
        anything(),
        "AwesomeController.custom_metrics.request_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["custom", "tag"],
        "ok",
        1,
        "my-awesome-metric"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["custom", "tag"],
        "ok",
        anything(),
        "my-awesome-timed-metric"
      )

      get 'custom_metrics'
    end

    it 'should be able to access the client after initialization' do

      expect(Riemann::Metrics.client).not_to be_nil
      expect(Riemann::Metrics.handler).not_to be_nil
      expect(Riemann::Metrics.client {|c| !c.nil? }).to eq true

    end

  end

end
