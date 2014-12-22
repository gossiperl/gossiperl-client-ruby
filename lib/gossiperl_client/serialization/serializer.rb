# encoding: ascii-8bit
require 'thrift'
require 'base64'
module Gossiperl
  module Client
    module Serialization
      class Serializer

        def serialize_arbitrary digest_type, digest_data
          transport = ::Thrift::MemoryBufferTransport.new()
          protocol = ::Thrift::BinaryProtocol.new(transport)
          protocol.write_struct_begin(digest_type.to_s)
          digest_data.each_key{|key|
            value = digest_data[key][:value]
            type  = self.type_to_thrift_type( digest_data[key][:type] )
            unless type.nil?
              protocol.write_field({ :type => type, :name => key.to_s }, digest_data[key][:field_id], value )
            else
              raise ArgumentError.new("Unsupported serializable type #{digest_data[key][:type]} for field #{key.to_s}.")
            end
          }
          protocol.write_field_stop
          protocol.write_struct_end

          envelope = Gossiperl::Client::Thrift::DigestEnvelope.new
          envelope.payload_type = digest_type.to_s
          envelope.bin_payload = Base64.strict_encode64( protocol.trans.read( protocol.trans.available ).force_encoding('UTF-8') )
          envelope.id = SecureRandom.uuid.to_s
          self.digest_to_binary( envelope )
        end

        def serialize digest
          digest_type = digest.class.name.split('::').last
          digest_type = digest_type[0].downcase + digest_type[1..digest_type.length]
          if digest_type == 'digestEnvelope'
            return self.digest_to_binary( envelope )
          end
          envelope = Gossiperl::Client::Thrift::DigestEnvelope.new
          envelope.payload_type = digest_type
          envelope.bin_payload = Base64.strict_encode64( self.digest_to_binary( digest ) )
          envelope.id = SecureRandom.uuid.to_s
          self.digest_to_binary( envelope )
        end

        def deserialize bin_digest
          envelope_resp = self.digest_from_binary('digestEnvelope', bin_digest)
          if envelope_resp.has_key?(:ok)
            embedded_type = self.digest_type_class( envelope_resp[:ok].payload_type )
            if embedded_type == :forward
              return { :forward => true,
                       :type => envelope_resp[:ok].payload_type,
                       :envelope => envelope_resp[:ok] }
            else
              payload = digest_from_binary(
                            envelope_resp[:ok].payload_type,
                            Base64.strict_decode64( envelope_resp[:ok].bin_payload ) )
              if payload.has_key?(:ok)
                return payload[:ok]
              else
                return { :error => :not_thrift }
              end
            end
          end
          return { :error => :not_thrift }
        end

        def digest_to_binary digest
          transport = ::Thrift::MemoryBufferTransport.new()
          protocol = ::Thrift::BinaryProtocol.new(transport)
          digest.write( protocol )
          protocol.trans.read( protocol.trans.available ).force_encoding('UTF-8')
        end

        def digest_from_binary digest_type, bin_digest
          begin
            transport = ::Thrift::MemoryBufferTransport.new( bin_digest )
            protocol = ::Thrift::BinaryProtocol.new(transport)
            digest = self.digest_type_class(digest_type).new
            digest.read( protocol )
            return { :ok => digest }
          rescue Exception => ex
            return { :error => ex }
          end
        end

        def digest_type_class digest_type
          types = {
            'digestError' => Gossiperl::Client::Thrift::DigestError,
            'digestForwardedAck' => Gossiperl::Client::Thrift::DigestForwardedAck,
            'digestEnvelope' => Gossiperl::Client::Thrift::DigestEnvelope,
            'digest' => Gossiperl::Client::Thrift::Digest,
            'digestAck' => Gossiperl::Client::Thrift::DigestAck,
            'digestSubscriptions' => Gossiperl::Client::Thrift::DigestSubscriptions,
            'digestExit' => Gossiperl::Client::Thrift::DigestExit,
            'digestSubscribe' => Gossiperl::Client::Thrift::DigestSubscribe,
            'digestSubscribeAck' => Gossiperl::Client::Thrift::DigestSubscribeAck,
            'digestUnsubscribe' => Gossiperl::Client::Thrift::DigestUnsubscribe,
            'digestUnsubscribeAck' => Gossiperl::Client::Thrift::DigestUnsubscribeAck,
            'digestEvent' => Gossiperl::Client::Thrift::DigestEvent
          }
          return types[ digest_type ] if types.has_key? digest_type
          return :forward
        end

        def type_to_thrift_type type
          type = type.to_sym
          serializable_thrift_types = {
                      :bool => ::Thrift::Types::BOOL,
                      :byte => ::Thrift::Types::BYTE,
                      :double => ::Thrift::Types::DOUBLE,
                      :i16 => ::Thrift::Types::I16,
                      :i32 => ::Thrift::Types::I32,
                      :i64 => ::Thrift::Types::I64,
                      :string => ::Thrift::Types::STRING }
          return (serializable_thrift_types)[ type ] if serializable_thrift_types.has_key? type
          return nil
        end

      end
    end
  end
end