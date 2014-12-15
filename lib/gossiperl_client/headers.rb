# encoding: ascii-8bit
module Gossiperl
  module Client

    class Resolution; end

    module Encryption
      class Aes256 < Gossiperl::Client::Resolution; end
    end

    module Serialization
      class Serializer; end
    end

    module Thrift
      class DigestEnvelope; end
      class DigestForwardedAck; end
      class DigestError; end
      class DigestExit; end
      class DigestMember; end
      class DigestSubscription; end
      class Digest; end
      class DigestAck; end
      class DigestSubscriptions; end
      class DigestSubscribe; end
      class DigestSubscribeAck; end
      class DigestUnsubscribe; end
      class DigestUnsubscribeAck; end
      class DigestEvent; end
    end

    module Transport
      class Udp < Gossiperl::Client::Resolution; end
    end

    module Util
      class Validation; end
    end

    class Messaging < Gossiperl::Client::Resolution; end
    class OverlayWorker < Gossiperl::Client::Resolution; end
    class State < Gossiperl::Client::Resolution; end
    class Supervisor < Gossiperl::Client::Resolution; end

  end
end