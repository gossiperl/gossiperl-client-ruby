# encoding: ascii-8bit
module Gossiperl
  module Client
    class Messaging < Gossiperl::Client::Resolution

      field :worker, Gossiperl::Client::OverlayWorker
      field :transport, Gossiperl::Client::Transport::Udp

      def initialize worker
        self.worker = worker
      end

      def start
        self.transport = Gossiperl::Client::Transport::Udp.new( self.worker )
        Thread.new(self) do |msg|
          msg.transport.handle do |data|
            if data.kind_of? Hash
              if data.has_key?(:error)
                # handle error
              elsif data.has_key?(:forward)
                # handle forward, forward message to the client and reply with digestForwardedAck
              else
                puts "Unsupported hash type response #{data}"
              end
            else
              if data.is_a?( Gossiperl::Client::Thrift::Digest )
                puts "Reply with digest ack"
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestAck )
                msg.worker.state.receive data
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestEvent )
                puts "member_... type of event"
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestSubscribeAck )
                puts "Confirmation of subscription"
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestUnsubscribeAck )
                puts "Confirmation of subscription removal"
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestForwardedAck )
                puts "Digest forwarded"
              else
                puts "Received unsupported #{data}"
              end
            end
          end
        end
      end

      def send digest
        self.transport.send digest
      end

    end
  end
end