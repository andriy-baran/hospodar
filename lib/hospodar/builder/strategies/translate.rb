# frozen_string_literal: true

module Hospodar
  module Builder
    module Strategies
      # Singleton for parsing schemas
      module Translate
        # Collects method calls in a given block
        Tracer = Struct.new(:yielder) do
          def method_missing(method_name, *attrs)
            yielder << [method_name, attrs.first]
          end

          def respond_to_missing?
            true
          end
        end

        ID_CLASS = Hospodar::Builder::Id

        ExecutionPlanMatrix = Struct.new(:collection) do
          def with_creation_procs(factory)
            self.collection = collection.map do |group, title|
              [group, title, factory.mother_ship_assembler_new_instance(group, title)]
            end
            self
          end

          def to_nested_form(builder_params)
            data = collection
            data.unshift(builder_params.to_a) unless builder_params.object.nil?
            intermediate_form = data.transpose
            tobe_assembled = intermediate_form[1..-1]
            keys = intermediate_form[0..1].transpose.map { |g, e| ID_CLASS.new(g, e) }
            tobe_assembled.first.pop
            tobe_assembled.first.unshift(nil)
            tobe_assembled << keys
            self.collection = tobe_assembled.transpose
            self
          end
        end

        class << self
          def call(reverse: false, &block)
            enum = trace(&block)
            return ExecutionPlanMatrix.new(enum) unless reverse

            ExecutionPlanMatrix.new(enum.reverse)
          end

          private

          def trace(&block)
            Tracer.new([]).tap { |tracer| tracer.instance_eval(&block) }.yielder
          end
        end
      end
    end
  end
end
