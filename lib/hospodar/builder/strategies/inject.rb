# frozen_string_literal: true

module Hospodar
  module Builder
    module Strategies
      # Allows user to pass parameters for creating new objects via method calls
      class Inject
        # User use it as configuration DSL for builder
        class Builder
          attr_reader :__result__, :__methods_allowlist__

          def initialize(list)
            @__result__ = {}
            @__methods_allowlist__ = list
            list.each do |method_name|
              define_singleton_method(method_name) do |*attrs|
                @__result__[method_name] = attrs
              end
            end
          end
        end

        def initialize(list, &block)
          @builder = Builder.new(list.map(&:to_sym))
          @block = block
        end

        def call
          @block&.call(@builder)
          @builder.__result__
        end
      end
    end
  end
end
