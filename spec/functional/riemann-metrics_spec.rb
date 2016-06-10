require 'spec_helper'
require 'riemann'


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

    it 'should collect metrics in opentsdb style if enabled' do
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        {controller: "AwesomeController", action: "index"},
        "ok",
        200,
        "http_status"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        {controller: "AwesomeController", action: "index"},
        "ok",
        anything(),
        "view_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        {controller: "AwesomeController", action: "index"},
        "ok",
        anything(),
        "request_runtime"
      )
      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        {controller: "AwesomeController", action: "index"},
        "ok",
        nil,
        "db_runtime"
      )
      Riemann::Metrics.opentsdb!

      get 'index'

      Riemann::Metrics.opentsdb!(false)
    end

    it 'should be able to access the client after initialization' do

      expect(Riemann::Metrics.client).not_to be_nil
      expect(Riemann::Metrics.handler).not_to be_nil
      expect(Riemann::Metrics.client {|c| !c.nil? }).to eq true

      Riemann::Metrics::Client.any_instance.should_receive(:gauge).with(
        ["tag"],
        "ok",
        1,
        "name"
      )

      Riemann::Metrics.client {|c| 
        c.report('name', 1, ['tag'])
      }
    end

    it "should accept key value tags" do
      Riemann::Metrics::Client.any_instance.should_receive(:add_event).with(
        {host: anything(),
         state: "ok",
         metric: 1,
         ttl: anything(),
         tags: contain_exactly("key=val", "env=test"),
         service: 'Rails.name'
      }) 

      Riemann::Metrics.client {|c| 
        c.report('name', 1, {key: "val"})
      }
    end

    it "should accept array tags" do
      Riemann::Metrics::Client.any_instance.should_receive(:add_event).with(
        {host: anything(),
         state: "ok",
         metric: 1,
         ttl: anything(),
         tags: contain_exactly("tag", "test"),
         service: 'Rails.name'
      }) 

      Riemann::Metrics.client {|c| 
        c.report('name', 1, ["tag"])
      }
    end

    it "should accept no tags when reporting without tags" do

      Riemann::Metrics::Client.any_instance.should_receive(:add_event).with(
        {host: anything(),
         state: "ok",
         metric: 1,
         ttl: anything(),
         tags: ["test"],
         service: 'Rails.serv'
      }) 

      Riemann::Metrics.client {|c| 
        c.report('serv', 1, nil)
      }

    end

    it "should accept no tags when reporting with tags" do
      Riemann::Metrics.opentsdb!

      Riemann::Metrics::Client.any_instance.should_receive(:add_event).with(
        {host: anything(),
         state: "ok",
         metric: 1,
         ttl: anything(),
         tags: ["env=test"],
         service: 'Rails.serv'
      }) 

      Riemann::Metrics.client {|c| 
        c.report('serv', 1, nil)
      }
      Riemann::Metrics.opentsdb!(false)

    end

    it "should be able to connect and fail for riemann with tcp" do

      #nonexist_host = '192.168.233.120'
      nonexist_host = nil
      cli = Riemann::Metrics::Client.new nonexist_host, nil, nil, nil, nil, {tcp_only: true}

      expect { cli.report('test', 1, []) }.to raise_error(Riemann::Client::TcpSocket::Error)
    end

  end

end
