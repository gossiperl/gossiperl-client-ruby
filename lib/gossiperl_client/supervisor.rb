# encoding: ascii-8bit
module Gossiperl
  module Client
    class Supervisor < Gossiperl::Client::Resolution

      field :connections, Hash, Hash.new

      def connect options, &block
        ::Gossiperl::Client::Util::Validation.validate_connect( options )
        if block_given?
          self.connections[ options[:overlay_name].to_sym ] = ::Gossiperl::Client::OverlayWorker.new(self, options, block)
        else
          self.connections[ options[:overlay_name].to_sym ] = ::Gossiperl::Client::OverlayWorker.new(self, options, nil)
        end
        self.connections[ options[:overlay_name].to_sym ].start
      end

      def disconnect overlay_name
        overlay_name = overlay_name.to_sym
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].stop
          self.connections.delete overlay_name
        else
          raise ArgumentError.new("[supervisor] No overlay connection: #{overlay_name}.")
        end
      end

      def subscriptions overlay_name
        overlay_name = overlay_name.to_sym
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].subscriptions
        else
          raise ArgumentError.new("[supervisor] No overlay connection: #{overlay_name}.")
        end
      end

      def subscribe overlay_name, event_types
        overlay_name = overlay_name.to_sym
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].subscribe event_types
        else
          raise ArgumentError.new("[supervisor] No overlay connection: #{overlay_name}.")
        end
      end

      def unsubscribe overlay_name, event_types
        overlay_name = overlay_name.to_sym
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].unsubscribe event_types
        else
          raise ArgumentError.new("[supervisor] No overlay connection: #{overlay_name}.")
        end
      end

      def stop
        self.connections.keys.each_value {|ow|
          ow.stop
        }
      end

    end
  end
end