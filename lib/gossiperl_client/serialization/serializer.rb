# encoding: ascii-8bit
require "thrift"

module Gossiperl
  module Client
    module Serialization
      class Serializer

        def serialize digest
          digest_type = digest.class.name.split('::').last
          digest_type = digest_type[0].downcase + digest_type[1..digest_type.length]
          if digest_type == 'digestEnvelope'
            return self.digest_to_binary( envelope )
          end
          envelope = Gossiperl::Client::Thrift::DigestEnvelope.new
          envelope.payload_type = digest_type
          envelope.bin_payload = self.digest_to_binary( digest )
          envelope.id = SecureRandom.uuid.to_s
          self.digest_to_binary( envelope )
        end

        def deserialize bin_digest
          envelope_resp = self.digest_from_binary("digestEnvelope", bin_digest)
          if envelope_resp.has_key?(:ok)
            embedded_type = self.digest_type_class( envelope_resp[:ok].payload_type )
            if embedded_type == :forward
              return { :forward => true,
                       :type => envelope_resp[:ok].payload_type,
                       :envelope => envelope_resp[:ok] }
            else
              payload = digest_from_binary(envelope_resp[:ok].payload_type, envelope_resp[:ok].bin_payload)
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
            "digestError" => Gossiperl::Client::Thrift::DigestError,
            "digestForwardedAck" => Gossiperl::Client::Thrift::DigestForwardedAck,
            "digestEnvelope" => Gossiperl::Client::Thrift::DigestEnvelope,
            "digest" => Gossiperl::Client::Thrift::Digest,
            "digestAck" => Gossiperl::Client::Thrift::DigestAck,
            "digestSubscriptions" => Gossiperl::Client::Thrift::DigestSubscriptions,
            "digestExit" => Gossiperl::Client::Thrift::DigestExit,
            "digestSubscribe" => Gossiperl::Client::Thrift::DigestSubscribe,
            "digestSubscribeAck" => Gossiperl::Client::Thrift::DigestSubscribeAck,
            "digestUnsubscribe" => Gossiperl::Client::Thrift::DigestUnsubscribe,
            "digestUnsubscribeAck" => Gossiperl::Client::Thrift::DigestUnsubscribeAck,
            "digestEvent" => Gossiperl::Client::Thrift::DigestEvent
          }
          return types[ digest_type ] if types.has_key? digest_type
          return :forward
        end

      end
    end
  end
end