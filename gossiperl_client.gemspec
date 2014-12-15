# encoding: ascii-8bit
$:.push File.expand_path("../lib", __FILE__)
require "gossiperl_client/version"

Gem::Specification.new do |s|
  s.name        = "gossiperl_client"
  s.version       = Gossiperl::Client::Version::VERSION
  s.has_rdoc      = false
  s.summary       = "Gossiperl Ruby client"
  s.description   = "Work with gossiperl from Ruby."
  s.authors       = ["Rad Gruchalski"]
  s.email         = ["radek@gruchalski.com"]
  s.homepage      = "https://github.com/radekg/gossiperl-client-ruby"
  s.require_paths = %w[lib]

  s.add_dependency('thrift', '>=0.9.2.0')
  s.add_development_dependency('shindo')
  
  s.files = %w[
    Gemfile
    README.md
    LICENSE
    lib/gossiperl_client.rb
    lib/gossiperl_client/encryption/aes256.rb
    lib/gossiperl_client/serialization/serializer.rb
    lib/gossiperl_client/thrift/gossiperl_constants.rb
    lib/gossiperl_client/thrift/gossiperl_types.rb
    lib/gossiperl_client/transport/udp.rb
    lib/gossiperl_client/util/validation.rb
    lib/gossiperl_client/headers.rb
    lib/gossiperl_client/messaging.rb
    lib/gossiperl_client/overlay_worker.rb
    lib/gossiperl_client/requirements.rb
    lib/gossiperl_client/resolution.rb
    lib/gossiperl_client/state.rb
    lib/gossiperl_client/supervisor.rb
    lib/gossiperl_client/version.rb
    gossiperl_client.gemspec
    tests/process_tests.rb
    tests/thrift_tests.rb
  ]
  s.test_files    = s.files.select { |path| path =~ /^[tests]\/.*_[tests]\.rb/ }
  
end