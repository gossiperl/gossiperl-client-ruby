# encoding: ascii-8bit
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/gossiperl_client/requirements.rb"
Shindo.tests('[Gossiperl] connect process') do

  @supervisor = Gossiperl::Client::Supervisor.new
  @options = {
    :overlay_name  => :gossiper_overlay_remote,
    :overlay_port  => 6666,
    :client_port   => 54321,
    :client_name   => :'ruby-client',
    :client_secret => :'ruby-client-secret',
    :symkey        => :v3JElaRswYgxOt4b }
  @subscriptions = [ :member_in, :digestForwardableTest ]

  tests('success') do

    tests('connect goes to connected').returns(true) do
      Thread.new(@supervisor) do |sup|
        sup.connect( @options ) do |event|
          if event[:event] == :connected
            self.logger.info "Connected to overlay #{event[:options][:overlay_name]}..."
          elsif event[:event] == :disconnected
            self.logger.info "Disconnected from overlay #{event[:options][:overlay_name]}..."
          elsif event[:event] == :subscribed
            self.logger.info "Received subscription confirmation for #{event[:details][:types]}"
          elsif event[:event] == :unsubscribed
            self.logger.info "Received unsubscription confirmation for #{event[:details][:types]}"
          elsif event[:event] == :event
            self.logger.info "Received member related event #{event[:details][:type]} for member #{event[:details][:member]}."
          elsif event[:event] == :forwarded_ack
            self.logger.info "Received confirmation of forwarded message. Message ID: #{event[:details][:reply_id]}"
          elsif event[:event] == :forwarded
            self.logger.info "Received forwarded digest #{event[:digest]} of type #{event[:digest_type]}"
          elsif event[:event] == :failed
            self.logger.info "Received an error from the client. Reason: #{event[:error]}."
          end
        end
      end
      sleep 3
      @supervisor.state( @options[:overlay_name] ) == :connected
    end

    tests('duplicate overlay').raises(ArgumentError) do
      @supervisor.connect( @options )
    end

    tests('subscribe').returns(true) do
      result = @supervisor.subscribe( @options[:overlay_name], @subscriptions ) == @subscriptions
      sleep 3
      result
    end

    tests('unsubscribe').returns(true) do
      result = @supervisor.unsubscribe( @options[:overlay_name], @subscriptions ) == []
      sleep 3
      result
    end

    tests('disconnect').returns(true) do
      @supervisor.disconnect( @options[:overlay_name] )
      sleep 1.5
      @supervisor.connections == {}
    end

  end

end