# encoding: ascii-8bit
require "../lib/gossiperl_client.rb"

digest = ::Gossiperl::Client::Thrift::Digest.new
digest.name = "test-client"
digest.port = 54321
digest.heartbeat = Time.now.to_i
digest.secret = "test-client-secret"
digest.id = SecureRandom.uuid.to_s

envelope = Gossiperl::Client::Serialization::Serializer.new.serialize(digest)
aes256 = Gossiperl::Client::Encryption::Aes256.new("v3JElaRswYgxOt4b", "wEKzHIGQDTdLknUE")
encrypted = aes256.encrypt(envelope)

puts "Encrypted length #{encrypted.length}"

File.open("/tmp/thrift.data", "wb") { |f| f.write(encrypted) }

from_file = File.binread("/tmp/thrift.data")
decrypted = aes256.decrypt(from_file)
read = Gossiperl::Client::Serialization::Serializer.new.deserialize(decrypted)
puts read

#deserialized = Gossiperl::Client::Serialization::Serializer.deserialize(envelope)

#puts deserialized.name, deserialized.port, deserialized.secret

exit 100

=begin
# serialize:
transport = Gossiperl::Client::Thrift::MemoryBufferTransport.new()
protocol = Thrift::BinaryProtocol.new(transport)

digest.write( protocol )

# inspect:
binary_data = protocol.trans.get_buf

# encrypt:

encrypted = .encrypt binary_data, "v3JElaRswYgxOt4b", "wEKzHIGQDTdLknUE"

puts "Encrypted data:"
puts "-----------------------------"
puts encrypted

decrypted = Gossiperl::Client::Encryption::Aes256.new.decrypt encrypted, 

# try deserialize:

in_transport = Gossiperl::Client::Thrift::MemoryBufferTransport.new( decrypted )
in_protocol = Thrift::BinaryProtocol.new(in_transport)
des = ::Gossiperl::Client::Thrift::Digest.new
des.read( in_protocol )

puts "Deserialized:"
puts "-----------------------------"

puts des.name, des.port, des.secret
=end
