# frozen_string_literal: true

module Hospodar
  module Builder
    # Implements wrap(&block) strategy in schemas
    class Wrapped < Assembler
      def initialize(factory, on_exception, delegate)
        super(factory, on_exception)
        @delegate = delegate
      end

      def on_planing(receiver)
        execution_plan(receiver, &dsl_block)
      end

      def on_building(receiver, plan, &on_create)
        building_steps(receiver, plan, &on_create)
      end

      private

      attr_reader :delegate

      def type
        :wrapped
      end

      def execution_plan(receiver, reverse: false)
        creation_matrix_from_dsl(receiver, reverse: reverse, &dsl_block).to_nested_form(builder_params).collection
      end

      def building_steps(receiver, plan, &on_create)
        inject = Strategies::Inject.new(plan.map(&:last), &on_create)
        init = Strategies::Init.new(inject, plan, target)
        link = Strategies::Link.new(init, delegate)
        Strategies::Enumerate.new(link, target, receiver, delegate)
      end
    end
  end
end
