# encoding: ascii-8bit
module Gossiperl
  module Client
    module Encryption
      class Aes256 < Gossiperl::Client::Resolution

        field :key, Object

        def initialize key_in
          # setup key:
          self.key = ::Digest::SHA256.digest(key_in)
        end
        
        def algorithm
          'AES-256-CBC'
        end

        def encrypt data
          random_iv = OpenSSL::Cipher::Cipher.new(algorithm).random_iv
          aes = ::OpenSSL::Cipher::Cipher.new(algorithm)
          aes.encrypt
          aes.key = self.key
          aes.iv = random_iv
          cipher = aes.update(data)
          cipher << aes.final
          random_iv + cipher
        end

        def decrypt cipher
          iv = cipher[0...16]
          cipher_data = cipher[16..-1]
          decode_cipher = ::OpenSSL::Cipher::Cipher.new(algorithm)
          decode_cipher.decrypt
          decode_cipher.key = self.key
          decode_cipher.padding = 0
          decode_cipher.iv = iv
          plain = decode_cipher.update(cipher_data)
          plain << decode_cipher.final
          plain
        end
      end
    end
  end
end