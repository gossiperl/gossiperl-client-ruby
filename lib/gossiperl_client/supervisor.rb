# encoding: ascii-8bit
module Gossiperl
  module Client
    class Supervisor < Gossiperl::Client::Resolution

      field :connections, Hash, Hash.new

      def connect options, &block
        ::Gossiperl::Client::Util::Validation.validate_connect( options )
        overlay_name = options[:overlay_name].to_sym
        raise ArgumentError.new("Client for #{overlay_name} already present.") if self.connections.has_key?(overlay_name)
        if block_given?
          self.connections[ overlay_name ] = ::Gossiperl::Client::OverlayWorker.new(self, options, block)
        else
          self.connections[ overlay_name ] = ::Gossiperl::Client::OverlayWorker.new(self, options, nil)
        end
        self.connections[ overlay_name ].start
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

      def state overlay_name
        overlay_name = overlay_name.to_sym
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].current_state
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

      def send overlay_name, digest_type, digest_data
        overlay_name = overlay_name.to_sym
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].send digest_type, digest_data
        else
          raise ArgumentError.new("[supervisor] No overlay connection: #{overlay_name}.")
        end
      end

      def read digest_type, binary_envelope, digest_info
        Gossiperl::Client::Serialization::Serializer.new.deserialize_arbitrary( digest_type, binary_envelope, digest_info )
      end

      def stop
        self.connections.keys.each_value {|ow|
          ow.stop
        }
      end

    end
  end
end