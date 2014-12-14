# encoding: ascii-8bit
require "../lib/gossiperl_client.rb"
require "thread"
Thread.abort_on_exception = true
#t = Thread.new do
supervisor = Gossiperl::Client::Supervisor.new
supervisor.connect( :overlay_name => "gossiper_overlay_remote",
                    :overlay_port => 6666,
                    :client_port => 54321,
                    :client_name => "ruby-client",
                    :client_secret => "ruby-client-secret",
                    :symkey => "v3JElaRswYgxOt4b",
                    :iv => "wEKzHIGQDTdLknUE" ) do |event|
  if event[:event] == :connected
    puts "Connected to overlay #{event[:options][:overlay_name]}..."
  elsif event[:event] == :disconnected
    puts "Disconnected from overlay #{event[:options][:overlay_name]}..."
  elsif event[:event] == :subscribed

  elsif event[:event] == :unsubscribed

  elsif event[:event] == :event

  elsif event[:event] == :forwarded_ack

  elsif event[:event] == :forwarded

  elsif event[:event] == :failed
    puts "Received an error from the client. Reason: #{event[:error]}."
  end

end
#end
#t.join