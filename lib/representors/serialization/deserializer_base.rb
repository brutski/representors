require 'representors/serialization/serialization_base'
require 'representors/serialization/deserializer_factory'

module Representors
  class DeserializerBase < SerializationBase
    def self.inherited(subclass)
      DeserializerFactory.register_deserializers(subclass)
    end

    # Returns back a class with all the information of the document and with convenience methods
    # to access it.
    def to_representor(options = {})
      Representor.new(to_hash(options))
    end

    # Returns a hash representation of the data. This is useful to merge with new data which may
    # be built by different builders. In this class we use it to support embedded resources.
    def to_hash(options = {})
      @serialization.call(options)
    end
    
  end
end
