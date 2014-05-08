require 'yaml'
require 'enumerable/lazy' if RUBY_VERSION < '2.0'

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Representor
  
    DOC_KEY = :doc
    LINK_KEY = :href
    PROTOCOL_KEY = :protocol
    SEMANTIC_KEY = :semantics
    EMBEDDED_KEY = :embedded
    LINK_KEY = :links
    TRANSITION_KEY = :transitions
    VALUE_KEY = :value
    UNKNOWN_PROTOCOL = 'ruby_id'
    DEFAULT_PROTOCOL = 'http'
    PROTOCOL_TEMPLATE = "%s://%s"
    
    
    # @param representor_hash [Hash] the abstract representor hash defining a resource
    def initialize(representor_hash = nil)
      @representor_hash = representor_hash || {}
    end
    
    # Returns the documentfor the representor
    #
    # @return [String] the document for the representor
    def doc
      doc = @representor_hash[DOC_KEY] || ''
      @doc ||= doc
    end
    
    # The URI for the object
    #
    # @note If the URI can't be made from the provided information it constructs one fromt the Ruby ID
    # @return [String]
    def identifier
      uri = @representor_hash[LINK_KEY] || self.object_id
      protocol = @representor_hash[PROTOCOL_KEY] || (uri == self.object_id ? UNKNOWN_PROTOCOL : DEFAULT_PROTOCOL)
      @identifier ||= PROTOCOL_TEMPLATE % [protocol, uri]
    end
    
    # @return [Hash] The hash representation of the object
    def to_hash
      @to_hash ||= @representor_hash
    end
    
    # @return [String] the yaml representation of the object 
    def to_yaml
      @to_yaml ||= YAML.dump(@representor_hash)
    end
    
    # @return [Hash] the resource attributes inferred from representor[:semantics]
    def properties
      attributes = @representor_hash[SEMANTIC_KEY] || {}
      @properties ||= Hash[ attributes.map { |k,v| [ k, v[VALUE_KEY]] } ]
    end
    
    # @return [Enumerable] who's elements are all <Crichton:Representor> objects
    def embedded
      embedded_elements = @representor_hash[EMBEDDED_KEY] || []
      @embedded ||= embedded_elements.lazy.map { |embed|  Representor.new(embed) }
    end
    
    # @return [Array] who's elements are all <Crichton:Transition> objects
    def meta_links
      links = @representor_hash[LINK_KEY] || []
      links = links.map { |k,v| { k => {href: v } } }
      @meta_links ||= get_transitions(links)
    end
    
    # @return [Array] who's elements are all <Crichton:Transition> objects    
    def transitions
      transitions = @representor_hash[TRANSITION_KEY] || []
      @transitions ||= get_transitions(transitions.map { |k, v| {k => v} })
    end

    # @return [Array] who's elements are all <Crichton:Option> objects    
    def datalists
      attributes = transitions.map { |transition| transition.attributes }
      parameters = transitions.map { |transition| transition.parameters }
      fields = [attributes, parameters].flatten
      options = fields.map { |field| field.options }
      @datalists = options.select { |o| o.datalist? }
    end
    
    private
    
    def get_transitions(hash)  
      hash.map { |h| Crichton::Transition.new(h) }
    end
  end
end

