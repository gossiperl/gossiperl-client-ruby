# encoding: ascii-8bit
require 'socket'
module Gossiperl
  module Client
    module Transport
      class Udp < Gossiperl::Client::Resolution

        field :worker, Gossiperl::Client::OverlayWorker
        field :socket, UDPSocket, nil
        field :recv_buf_size, Fixnum, 16777216

        field :serializer, Gossiperl::Client::Serialization::Serializer
        field :encryption, Gossiperl::Client::Encryption::Aes256

        def initialize worker
          self.worker = worker
          self.serializer = Gossiperl::Client::Serialization::Serializer.new
          self.encryption = Gossiperl::Client::Encryption::Aes256.new(
                                                self.worker.options[:symkey].to_s,
                                                self.worker.options[:iv].to_s )
        end

        def handle &block
          worker = Thread.new ({ :proto => self, :block => block }) do |args|
            begin
              args[:proto].socket = UDPSocket.new
              args[:proto].socket.bind '127.0.0.1', args[:proto].worker.options[:client_port]
              while args[:proto].worker.working
                begin
                  data, address = args[:proto].socket.recvfrom args[:proto].recv_buf_size
                  decrypted = args[:proto].encryption.decrypt(data)
                  deserialized = args[:proto].serializer.deserialize(decrypted)
                  args[:block].call deserialized
                rescue Exception => ex
                  args[:block].call({ :error => ex })
                end
              end
              self.socket.close unless self.socket.nil?
              args[:proto].worker.logger.debug("Stopping UDP services for client #{args[:proto].worker.options[:client_name]}.")
            rescue Exception => e
              args[:proto].worker.logger.error("Could not bind UDP service for client #{args[:proto].worker.options[:client_name]}.")
            end
          end
        end
      
        def send digest
          serialized = self.serializer.serialize digest
          encrypted  = self.encryption.encrypt serialized
          self.socket.send encrypted, 0, '127.0.0.1', self.worker.options[:overlay_port]
        end
      end
    end
  end
end