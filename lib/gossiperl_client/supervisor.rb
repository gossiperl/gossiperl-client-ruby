# encoding: ascii-8bit
module Gossiperl
  module Client
    class Supervisor < Gossiperl::Client::Resolution

      field :connections, Hash, Hash.new

      def connect options={}, &block
        if block_given?
          self.connections[ options[:name] ] = Gossiperl::Client::OverlayWorker.new(options, block)
        else
          self.connections[ options[:name] ] = Gossiperl::Client::OverlayWorker.new(options)
        end
        self.connections[ options[:name] ].start
      end

      def disconnect overlay_name
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].stop
          self.connections.delete overlay_name
        else
          raise "No overlay connection: #{overlay_name}"
        end
      end

      def subscriptions overlay_name
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].subscriptions
        else
          raise "No overlay connection: #{overlay_name}"
        end
      end

      def subscribe overlay_name, event_types
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].subscribe event_types
        else
          raise "No overlay connection: #{overlay_name}"
        end
      end

      def unsubscribe overlay_name, event_types
        if self.connections.has_key? overlay_name
          self.connections[ overlay_name ].unsubscribe event_types
        else
          raise "No overlay connection: #{overlay_name}"
        end
      end

    end
  end
end