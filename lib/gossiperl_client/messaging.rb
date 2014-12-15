# encoding: ascii-8bit
module Gossiperl
  module Client
    class Messaging < Gossiperl::Client::Resolution

      field :worker, Gossiperl::Client::OverlayWorker
      field :transport, Gossiperl::Client::Transport::Udp

      def initialize worker, &block
        self.worker = worker
        @callback_block = block
      end

      def get_callback_block
        @callback_block
      end

      def start
        self.transport = Gossiperl::Client::Transport::Udp.new( self.worker )
        if self.worker.options.has_key?(:thrift_window)
          self.transport.recv_buf_size = self.worker.options[:thrift_window]
        end
        Thread.new(self) do |msg|
          msg.transport.handle do |data|
            if data.kind_of? Hash
              if data.has_key?(:error)
                msg.worker.process_event( { :event => :failed,
                                            :error => data[:error] } )
              elsif data.has_key?(:forward)
                msg.worker.process_event( { :event => :forwarded,
                                            :digest => data[:envelope],
                                            :digest_type => data[:type] } )
                msg.digest_forwarded_ack data[:envelope].id
              else
                msg.worker.process_event( { :event => :failed,
                                            :error => { :unsupported_hash_response => data } } )
              end
            else
              if data.is_a?( Gossiperl::Client::Thrift::Digest )
                msg.digest_ack data
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestAck )
                msg.worker.state.receive data
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestEvent )
                msg.worker.process_event( { :event => :event,
                                            :details => { :type => data.event_type,
                                                          :member => data.event_object,
                                                          :heartbeat => data.heartbeat } } )
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestSubscribeAck )
                msg.worker.process_event( { :event => :subscribed,
                                            :details => { :types => data.event_types.map{|item| item.to_sym},
                                                          :heartbeat => data.heartbeat } } )
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestUnsubscribeAck )
                msg.worker.process_event( { :event => :unsubscribed,
                                            :details => { :types => data.event_types.map{|item| item.to_sym},
                                                          :heartbeat => data.heartbeat } } )
              elsif data.is_a?( Gossiperl::Client::Thrift::DigestForwardedAck )
                msg.worker.process_event( { :event => :forwarded_ack,
                                            :details => { :reply_id => data.reply_id } } )
              else
                msg.worker.process_event( { :event => :failed,
                                            :error => { :unsupported_digest => data } } )
              end
            end
          end
        end
      end

      def send digest
        self.transport.send digest
      end

      def digest_ack digest
        ack = ::Gossiperl::Client::Thrift::DigestAck.new
        ack.name = self.worker.options[:client_name].to_s
        ack.heartbeat = Time.now.to_i
        ack.reply_id = digest.id
        ack.membership = []
        self.send ack
      end

      def digest_forwarded_ack digest_id
        ack = ::Gossiperl::Client::Thrift::DigestForwardedAck.new
        ack.name = self.worker.options[:client_name].to_s
        ack.secret = self.worker.options[:client_secret].to_s
        ack.reply_id = digest_id
        self.send ack
      end

      def digest_subscribe event_types
        digest = ::Gossiperl::Client::Thrift::DigestSubscribe.new
        digest.name = self.worker.options[:client_name].to_s
        digest.secret = self.worker.options[:client_secret].to_s
        digest.id = SecureRandom.uuid.to_s
        digest.heartbeat = Time.now.to_i
        digest.event_types = event_types.map{|item| item.to_s}
        self.send digest
      end

      def digest_unsubscribe event_types
        digest = ::Gossiperl::Client::Thrift::DigestUnsubscribe.new
        digest.name = self.worker.options[:client_name].to_s
        digest.secret = self.worker.options[:client_secret].to_s
        digest.id = SecureRandom.uuid.to_s
        digest.heartbeat = Time.now.to_i
        digest.event_types = event_types.map{|item| item.to_s}
        self.send digest
      end

      def digest_exit
        digest = ::Gossiperl::Client::Thrift::DigestExit.new
        digest.name = self.worker.options[:client_name].to_s
        digest.heartbeat = Time.now.to_i
        digest.secret = self.worker.options[:client_secret].to_s
        self.send digest
        self.worker.working = false
      end

    end
  end
end