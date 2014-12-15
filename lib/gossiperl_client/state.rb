# encoding: ascii-8bit
require 'securerandom'
module Gossiperl
  module Client
    class State < Gossiperl::Client::Resolution

      field :worker, Gossiperl::Client::OverlayWorker
      field :connected, [TrueClass,FalseClass], false
      field :last_ts, Fixnum
      field :subscriptions, Array, []

      def initialize worker
        self.worker = worker
      end

      def start
        sleep 1
        self.last_ts = Time.now.to_i
        Thread.new(self) do |state|
          while state.worker.working
            state.send_digest
            sleep 2
            if Time.now.to_i - state.last_ts > 5
              if self.connected
                # Announce disconnected
                state.worker.process_event( { :event => :disconnected } )
                self.connected = false
              end
            end
          end
          state.worker.process_event( { :event => :disconnected } )
          self.connected = false
          state.worker.logger.info("Stopping state service for client #{state.worker.options[:client_name]}.")
        end
      end

      def receive digest_ack
        unless self.connected
          # Announce connected
          self.worker.process_event( { :event => :connected } )
          self.worker.messaging.digest_subscribe( self.subscriptions ) if self.subscriptions.length > 0
        end
        self.connected = true
        self.last_ts = digest_ack.heartbeat
      end

      def send_digest
        digest = Gossiperl::Client::Thrift::Digest.new
        digest.name = self.worker.options[:client_name].to_s
        digest.port = self.worker.options[:client_port]
        digest.heartbeat = Time.now.to_i
        digest.id = SecureRandom.uuid.to_s
        digest.secret = self.worker.options[:client_secret].to_s
        self.worker.messaging.send digest
      end

      def subscribe event_types
        ::Gossiperl::Client::Util::Validation.validate_event_types( event_types )
        self.subscriptions = self.subscriptions + event_types
        self.worker.messaging.digest_subscribe(event_types) if self.connected
        return self.subscriptions
      end

      def unsubscribe event_types
        ::Gossiperl::Client::Util::Validation.validate_event_types( event_types )
        self.subscriptions = self.subscriptions - event_types
        self.worker.messaging.digest_unsubscribe(event_types) if self.connected
        return self.subscriptions
      end

    end
  end
end