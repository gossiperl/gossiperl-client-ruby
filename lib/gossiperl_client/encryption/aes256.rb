# encoding: ascii-8bit
module Gossiperl
  module Client
    module Encryption
      class Aes256 < Gossiperl::Client::Resolution

        field :key, Object
        field :iv, Object

        def initialize key_in, iv_in
          # setup iv
          self.iv = iv_in
          # setup key:
          self.key = ::Digest::SHA256.digest(key_in)
        end
        
        def algorithm
          "AES-256-CBC"
        end

        def encrypt data
          aes = ::OpenSSL::Cipher::Cipher.new(algorithm)
          aes.encrypt
          aes.key = self.key
          aes.iv = self.iv
          cipher = aes.update(data)
          cipher << aes.final
          cipher
        end

        def decrypt cipher
          decode_cipher = ::OpenSSL::Cipher::Cipher.new(algorithm)
          decode_cipher.decrypt
          decode_cipher.key = self.key
          decode_cipher.padding = 0
          decode_cipher.iv = self.iv
          plain = decode_cipher.update(cipher)
          plain << decode_cipher.final
          plain
        end
      end
    end
  end
end