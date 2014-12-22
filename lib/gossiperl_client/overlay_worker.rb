# encoding: ascii-8bit
require 'logger'
module Gossiperl
  module Client
    class OverlayWorker < Gossiperl::Client::Resolution

      field :options, Hash
      field :supervisor, Gossiperl::Client::Supervisor
      field :messaging, Gossiperl::Client::Messaging
      field :state, Gossiperl::Client::State
      field :working, [FalseClass,TrueClass]
      field :logger, Logger

      def initialize supervisor, options, block
        raise ArgumentError.new('Supervisor must be of type Supervisor.') unless supervisor.is_a?(::Gossiperl::Client::Supervisor)
        raise ArgumentError.new('Callback must be a Proc / block.') unless block.nil? or block.is_a?(Proc)
        ::Gossiperl::Client::Util::Validation.validate_connect( options )
        self.supervisor = supervisor
        self.options = options
        self.working = true
        @callback_block = block
        if options.has_key?(:logger)
          self.logger - options[:logger]
        else
          self.logger = Logger.new(STDOUT)
          self.logger.level = Logger::DEBUG
        end
      end

      def start
        self.messaging = Gossiperl::Client::Messaging.new(self)
        self.state     = Gossiperl::Client::State.new(self)
        [self.messaging.start, self.state.start].each {|worker|
          worker.join
        }
      end

      def stop
        self.messaging.digest_exit
        while self.state.connected
          sleep 0.1
        end
      end

      def current_state
        return :connected if self.state.connected
        return :disconnected
      end

      def process_event event
        unless @callback_block.nil?
          self.instance_exec event.merge( { :options => self.options } ), &@callback_block
        else
          self.logger.info("[#{self.options[:client_name]}] Processing event: #{event}.")
        end
      end

      def subscribe event_types
        self.state.subscribe event_types
      end

      def unsubscribe event_types
        self.state.unsubscribe event_types
      end

      def send digest_type, digest_data
        begin
          serialized = self.messaging.transport.serializer.serialize_arbitrary( digest_type, digest_data )
          self.messaging.send serialized
        rescue ArgumentError => e
          process_event( { :event => :failed,
                           :error => { :serialize_arbitrary => e } } )
        end
      end
      
    end
  end
end