# encoding: ascii-8bit
module Gossiperl
  module Client
    class OverlayWorker < Gossiperl::Client::Resolution

      field :options, Hash
      field :subscriptions, Array, []
      field :messaging, Gossiperl::Client::Messaging
      field :state, Gossiperl::Client::State
      field :working, [FalseClass,TrueClass]

      def initialize options={}
        self.options = options
        self.working = true
      end

      def start
        self.messaging = Gossiperl::Client::Messaging.new(self)
        self.state     = Gossiperl::Client::State.new(self)
        [self.messaging.start, self.state.start].each {|worker|
          worker.join
        }
      end

      def current_state
        return :connected if self.state.connected
        return :disconnected
      end
      
    end
  end
end