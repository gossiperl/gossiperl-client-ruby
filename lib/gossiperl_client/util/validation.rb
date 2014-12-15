# encoding: ascii-8bit
module Gossiperl
  module Client
    module Util

      class Validation

        def self.validate_connect options
          raise ArgumentError.new('Options must be a Hash.') unless options.kind_of?(Hash)
          [ :overlay_name, :client_name, :client_secret, :overlay_port, :client_port, :symkey, :iv ].each {|opt|
            raise ArgumentError.new("Required option #{opt} missing.") unless options.has_key?(opt)
          }
          [ :overlay_name, :client_name, :client_secret, :symkey, :iv ].each {|str_opt|
            raise TypeError.new("Option #{str_opt} must be a String or Symbol.") unless [String, Symbol].include?( options[str_opt].class )
          }
          [ :overlay_port, :client_port ].each {|fixnum_opt|
            raise TypeError.new("Option #{str_opt} must be a Fixnum.") unless [Fixnum].include?( options[fixnum_opt].class )
          }
          if options.has_key?(:thrift_window) and not options[:thrift_window].is_a?(Fixnum)
            raise TypeError.new('Option thrift_window has to be a Fixnum.')
          end
          if options.has_key?(:logger) and not options[:logger].kind_of?(Logger)
            raise TypeError.new('Option logger must be an instance of Logger.')
          end
        end

        def self.validate_event_types event_types
          event_types.each {|et|
            raise TypeError.new("Event type #{et.inspect} must be a String or Symbol.") unless  [String, Symbol].include?( et.class )
          }
        end

      end

    end
  end
end