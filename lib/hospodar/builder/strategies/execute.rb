# frozen_string_literal: true

module Hospodar
  module Builder
    module Strategies
      # Runs building process
      class Execute
        attr_reader :strategy, :target, :factory

        def initialize(strategy, target, factory)
          @strategy = strategy
          @target = target
          @factory = factory
        end

        def call(type = nil, &block)
          run_with_error_handling { process(type, &block) }
          prepare_top
        end

        private

        def process(type = nil, &block)
          build_plan.take_while do |object, id|
            next true unless block

            run_build_step(object, id, type, &block)
          end
        end

        def run_build_step(object, id, type)
          run_with_error_handling(return_value: false) do
            res = yield(object, id)
            type == :do_while ? res : !res
          end
        end

        def run_with_error_handling(return_value: nil)
          yield
        rescue StandardError => e
          handle_exception(e)
          return_value
        end

        def build_plan
          @build_plan ||= strategy.call
        end

        def handle_exception(exc)
          target.on_exception ||= factory.on_exception
          target.exception = wrap_error(exc)
          exetute_exception_strategy(target.exception, target.on_exception, target)
        end

        def wrap_error(exc)
          return exc if exc.is_a?(Hospodar::Builder::InstantiationError)

          Hospodar::Builder.create_error(exc, strategy.step_id)
        end

        def exetute_exception_strategy(exc, on_exception, target)
          case on_exception
          when Proc
            on_exception.call(exc, target)
          when :raise
            raise(exc)
          end
        end

        def prepare_top
          target
        end
      end
    end
  end
end
