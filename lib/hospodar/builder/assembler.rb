# frozen_string_literal: true

require 'hospodar/builder/strategies/execute'
require 'hospodar/builder/strategies/enumerate'
require 'hospodar/builder/strategies/translate'
require 'hospodar/builder/strategies/inject'
require 'hospodar/builder/strategies/init'
require 'hospodar/builder/strategies/link'
require 'hospodar/builder/strategies/mount'

module Hospodar
  module Builder
    BuilderParams = Struct.new(:object, :title, :group) do
      def to_a
        [group, title, proc { object }]
      end

      def check!
        return unless invalid?

        raise(ArgumentError, 'Please provide object: and title: arguments')
      end

      def invalid?
        (group.nil? && title.nil?) ^ object.nil?
      end
    end

    # Base class for writing methods that are supported in schemas
    class Assembler
      attr_accessor :builder_params, :target, :on_exception, :planing_method,
                    :execution_method, :build_method, :new_struct_method

      def initialize(factory, on_exception)
        @factory = factory
        @on_exception = on_exception
      end

      def for(name, &block)
        @name = name
        @planing_method = :"hospodar_perform_planing_for_#{name}"
        @execution_method = :"hospodar_execute_plan_for_#{name}"
        @build_method = :"build_#{name}"
        @new_struct_method = :"new_#{name}_#{type}_struct_instance"
        @dsl_block = block
        self
      end

      def inject_method
        define_planing_method
        define_plan_execution_method
        define_building_method
      end

      private

      attr_reader :factory, :name, :dsl_block

      def define_planing_method
        assembler = self
        factory.define_singleton_method(@planing_method) do |object, title, group|
          assembler.builder_params = BuilderParams.new(object, title, group).tap(&:check!)
          assembler.target = public_send(assembler.new_struct_method)
          assembler.target.on_exception = assembler.on_exception
          assembler.on_planing(self)
        end
        factory.private_class_method @planing_method
      end

      def define_plan_execution_method
        assembler = self
        factory.define_singleton_method(@execution_method) do |plan, &on_create|
          process = assembler.on_building(self, plan, &on_create)
          Proxy.new(process)
        end
        factory.private_class_method @execution_method
      end

      def define_building_method
        assembler = self
        factory.define_singleton_method(build_method) do |object: nil, title: nil, group: nil, &on_create|
          plan = send(assembler.planing_method, object, title, group)
          send(assembler.execution_method, plan, &on_create)
        end
      end

      def creation_matrix_from_dsl(factory, reverse: nil, &block)
        trace_dsl_block(reverse: reverse, &block).with_creation_procs(factory)
      end

      def trace_dsl_block(reverse: nil, &block)
        Strategies::Translate.call(reverse: reverse, &block)
      end
    end
  end
end
