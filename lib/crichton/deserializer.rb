module Crichton

  # Error to raise when the format we are trying to de/serialize is not known by Crichton
  class UnknownFormatError < StandardError
  end

  # This is a convenience class, it can be used as main entry point to this library.
  # The only puporse is to find the correct deserializer.
  class Deserializer
    # Following the factory pattern, this class will just have a create method.
    # Defined in the class itself.
    class << self
      def create(format, document)
        serializer = serializers_mapping[format]
        if serializer
          return serializer.new(document)
        else
          raise UnknownFormatError, "Crichton can not deserialize #{format}"
        end
      end

      private
      def serializers_mapping
        {
          #A Hale document is a valid Hal document, use hal deserializer till hale's is ready.
          "application/vnd.hale+json" => Crichton::HalDeserializer,
          "application/hal+json" => Crichton::HalDeserializer
        }
      end
    end
  end
end