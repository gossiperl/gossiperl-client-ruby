# encoding: ascii-8bit
module Gossiperl
  module Client
    class Resolution
    
      UNDEFINED_VALUE = 'GOSSIPERL_UNDEFINED_VALUE'

      def self.field(name, types, default_value=Resolution::UNDEFINED_VALUE)
        name = name.to_s
        define_method("#{name}=") do |value|
          if value.nil?
            type_matched = true
          else
            type_matched = false
            types = [types] unless types.is_a? Array
            types.each do |type|
              type_matched = true if value.is_a? type and not type_matched
            end
          end
          if type_matched
            self.instance_variable_set("@#{name}", value)
          else
            raise ArgumentError, "Invalid argument value type for #{name}. Required one of #{types.inspect}, received #{value.class}"
          end
        end
        
        define_method("#{name}") do
          if default_value != Resolution::UNDEFINED_VALUE
            self.instance_variable_set("@#{name}", default_value) unless self.instance_variable_defined? "@#{name}"
          end
          self.instance_variable_get("@#{name}")
        end
        
      end
    
    end
  end
end