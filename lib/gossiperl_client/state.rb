# encoding: ascii-8bit
require 'securerandom'
module Gossiperl
  module Client
    class State < Gossiperl::Client::Resolution

      field :worker, Gossiperl::Client::OverlayWorker
      field :connected, [TrueClass,FalseClass], false
      field :last_ts, Fixnum

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
        end
      end

      def receive digest_ack
        unless self.connected
          # Announce connected
          self.worker.process_event( { :event => :connected } )
        end
        self.connected = true
        self.last_ts = digest_ack.heartbeat
      end

      def send_digest
        digest = Gossiperl::Client::Thrift::Digest.new
        digest.name = self.worker.options[:client_name]
        digest.port = self.worker.options[:client_port]
        digest.heartbeat = Time.now.to_i
        digest.id = SecureRandom.uuid.to_s
        digest.secret = self.worker.options[:client_secret]
        self.worker.messaging.send digest
      end

    end
  end
end