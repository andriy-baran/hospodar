# frozen_string_literal: true

module Hospodar
  module Builder
    module Strategies
      # Does final steps after completing building process for nested structures
      class Enumerate < Execute
        attr_reader :delegate

        def initialize(strategy, target, factory, delegate)
          super(strategy, target, factory)
          @delegate = delegate
        end

        private

        def prepare_top
          return target if strategy.object.nil?

          Hospodar::Builder.def_accessor(strategy.last_step, on: target, to: strategy.object, delegate: delegate)
          target
        end
      end
    end
  end
end
