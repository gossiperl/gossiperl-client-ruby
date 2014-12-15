# encoding: ascii-8bit
require "../lib/gossiperl_client.rb"
require "thread"
Thread.abort_on_exception = true
supervisor = Gossiperl::Client::Supervisor.new

t = Thread.new(supervisor) do |supervisor|
  supervisor.connect( :overlay_name => :gossiper_overlay_remote,
                      :overlay_port => 6666,
                      :client_port => 54321,
                      :client_name => :'ruby-client',
                      :client_secret => :'ruby-client-secret',
                      :symkey => :v3JElaRswYgxOt4b,
                      :iv => :wEKzHIGQDTdLknUE ) do |event|
    
    if event[:event] == :connected

      self.logger.info "Connected to overlay #{event[:options][:overlay_name]}..."
      self.subscribe [ :member_in, :digestForwardableTest ]

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
t.join