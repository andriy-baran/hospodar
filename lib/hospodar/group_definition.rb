# frozen_string_literal: true

module Hospodar
  # Extracts configuration params from code block
  class GroupDefinition
    attr_reader :definitions

    def initialize
      @definitions = {}
    end

    def method_missing(name, **kws)
      @definitions[name] = kws.keep_if do |key, _|
        %i[base_class init].include?(key)
      end
    end

    def respond_to_missing?
      true
    end
  end
end
