# encoding: ascii-8bit
module Gossiperl
  module Client
    class OverlayWorker < Gossiperl::Client::Resolution

      field :options, Hash
      field :subscriptions, Array, []
      field :messaging, Gossiperl::Client::Messaging
      field :state, Gossiperl::Client::State
      field :working, [FalseClass,TrueClass]

      def initialize options={}, block
        self.options = options
        self.working = true
        @callback_block = block
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

      def process_event event
        unless @callback_block.nil?
          @callback_block.call( event.merge( { :options => self.options } ) )
        else
          puts "Event received: #{event}"
        end
      end
      
    end
  end
end