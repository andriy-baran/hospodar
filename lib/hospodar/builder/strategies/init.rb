# frozen_string_literal: true

module Hospodar
  module Builder
    module Strategies
      # Creates objects for nest and wrap strategies
      class Init
        attr_reader :strategy, :pipe, :target

        def initialize(strategy, pipe, target)
          @strategy = strategy
          @pipe = pipe
          @target = target
        end

        def call
          Enumerator.new do |yielder|
            instantiate_objects(yielder)
          end.lazy
        end

        private

        def instantiate_objects(yielder)
          pipe.each do |title, init_proc, id|
            object = create_object(init_proc, id)
            next if object.nil? && target.ignore_exceptions?

            yielder << [title, create_object(init_proc, id), id]
          end
        end

        def create_object(init_proc, id)
          init_proc.call(*init_attrs_for(id))
        rescue StandardError => e
          handle_exception(e, id, init_attrs_for(id))
        end

        def init_attrs_for(id)
          Array(init_params[id.to_sym])
        end

        def init_params
          @init_params ||= strategy.call
        end

        def handle_exception(exc, id, init_attrs)
          exception = Hospodar::Builder.create_init_error(exc, id, init_attrs)
          target.exception = exception
          raise exception unless target.ignore_exceptions?
        end
      end
    end
  end
end
