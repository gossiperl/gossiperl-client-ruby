# encoding: ascii-8bit
module Gossiperl
  module Client
    module Thrift
      class MemoryBufferTransport < ::Thrift::MemoryBufferTransport
        def get_buf
          @buf
        end
      end
    end
  end
end