# encoding: ascii-8bit
$:.push File.expand_path("../lib", __FILE__)
require "gossiperl_client/version"

Gem::Specification.new do |s|
  s.name        = "gossiperl_client"
  s.version     = Gossiperl::Client::Version::VERSION
  s.has_rdoc    = false
  s.authors     = ["Rad Gruchalski"]
  s.email       = ["radek@gruchalski.com"]
  s.summary     = "Gossiperl Ruby client"
  s.description = s.summary
  s.extra_rdoc_files = [ "LICENSE" ]
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {tests}/*`.split("\n")
  %w(shindo).each { |gem| s.add_development_dependency gem }
  s.require_paths = ["lib"]
end