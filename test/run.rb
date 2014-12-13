# encoding: ascii-8bit
require "../lib/gossiperl_client.rb"
#t = Thread.new do
  supervisor = Gossiperl::Client::Supervisor.new
  supervisor.connect( :overlay_name => "gossiper_overlay_remote",
                    :overlay_port => 6666,
                    :client_port => 54321,
                    :client_name => "ruby-client",
                    :client_secret => "ruby-client-secret",
                    :symkey => "v3JElaRswYgxOt4b",
                    :iv => "wEKzHIGQDTdLknUE" )
#end
#t.join