# encoding: ascii-8bit
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/gossiperl_client/requirements.rb"
Shindo.tests('[Thrift] Serialize / deserialize') do

  @digest = digest = ::Gossiperl::Client::Thrift::Digest.new
  @digest.name = "test-client"
  @digest.port = 54321
  @digest.heartbeat = Time.now.to_i
  @digest.secret = "test-client-secret"
  @digest.id = "test-digest-id"

  @enc_key = "SomeEncryptionKe"

  tests('success') do
    
    tests('serialize / deserialize').returns(true) do
      envelope = Gossiperl::Client::Serialization::Serializer.new.serialize(@digest)
      read = Gossiperl::Client::Serialization::Serializer.new.deserialize(envelope)
      read.id == @digest.id
    end

    tests('encrypt / decrypt').returns(true) do
      envelope = Gossiperl::Client::Serialization::Serializer.new.serialize(@digest)
      encrypted = Gossiperl::Client::Encryption::Aes256.new(@enc_key).encrypt(envelope)
      decrypted = Gossiperl::Client::Encryption::Aes256.new(@enc_key).decrypt(encrypted)
      read = Gossiperl::Client::Serialization::Serializer.new.deserialize(decrypted)
      read.id == @digest.id
    end

    tests('serialize / deserialize arbitrary').returns(true) do
      serializer = Gossiperl::Client::Serialization::Serializer.new
      serialized_data = serializer.serialize_arbitrary :digestForwardableTest, {
        :string_property => { :value => "some string",
                              :type => :string,
                              :field_id => 1 },
        :some_port => { :value => 1234567890,
                        :type => :i32,
                        :field_id => 2 },
      }
      true
    end

  end

end