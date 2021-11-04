# frozen_string_literal: true

module Hospodar
  module Builder
    # Implements flat(&block) strategy in schemas
    class Flatten < Assembler
      def on_planing(receiver)
        execution_plan(receiver, &dsl_block)
      end

      def on_building(receiver, plan, &on_create)
        building_steps(receiver, plan, &on_create)
      end

      private

      def type
        :flatten
      end

      def building_steps(receiver, plan, &block)
        inject = Strategies::Inject.new(plan.map(&:first), &block)
        mount = Strategies::Mount.new(inject, plan, target, builder_params.title)
        Strategies::Execute.new(mount, target, receiver)
      end

      def execution_plan(receiver)
        plan = creation_matrix_from_dsl(receiver, &dsl_block).collection
        plan.unshift(builder_params.to_a) unless builder_params.object.nil?
        plan = plan.transpose
        ids = plan[0..1].transpose.map { |g, e| Hospodar::Builder::Id.new(g, e) }
        ids.zip(plan[-1])
      end
    end
  end
end
