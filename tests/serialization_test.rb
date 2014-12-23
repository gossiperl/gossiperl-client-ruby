# encoding: ascii-8bit
require "#{File.expand_path(File.dirname(__FILE__))}/../lib/gossiperl_client/requirements.rb"
Shindo.tests('[Gossiperl] connect process') do

  @serializer = Gossiperl::Client::Serialization::Serializer.new
  @digest_type = "someCustomDigest"
  @digest_data = {
    :some_property => { :value => "some string property", :type => :string, :field_id => 1 },
    :some_other_property => { :value => 1234, :type => :i32, :field_id => 2 },
  }
  @digest_info = {
    :some_property => { :type => :string, :field_id => 1 },
    :some_other_property => { :type => :i32, :field_id => 2 }
  }

  tests('success') do

    tests('serialize_deserialize').returns(true) do
      binary_envelope = @serializer.serialize_arbitrary(@digest_type, @digest_data)
      deserialized    = @serializer.deserialize_arbitrary( @digest_type, binary_envelope, @digest_info )
      deserialized.is_a?(Hash) && deserialized.has_key?(:some_property) && deserialized.has_key?(:some_other_property)
    end

  end

end