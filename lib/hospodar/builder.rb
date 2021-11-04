# frozen_string_literal: true

require 'hospodar/builder/id'
require 'hospodar/builder/proxy'
require 'hospodar/builder/assembler'
require 'hospodar/builder/flatten'
require 'hospodar/builder/wrapped'
require 'hospodar/builder/nested'
require 'hospodar/builder/helpers'
require 'hospodar/builder/instantiation_error'
require 'hospodar/builder/error'
require 'hospodar/builder/exeptional'

module Hospodar
  # Introduces possibilty to build complex objects by schema
  module Builder
    # Handles method delegation
    module MethodMissingDelegation
      def method_missing(name, *attrs, &block)
        return super unless methods.detect { |m| m == :ms_predecessor }

        public_send(ms_predecessor).public_send(name, *attrs, &block)
      end

      def respond_to_missing?(method_name, _include_private = false)
        return super unless methods.detect { |m| m == :ms_predecessor }

        public_send(ms_predecessor).respond_to?(method_name)
      end
    end

    private_constant :Assembler
    private_constant :Proxy
    private_constant :Helpers
    private_constant :Exceptional
    private_constant :Strategies
    private_constant :MethodMissingDelegation

    class Error < StandardError; end

    def self.create_init_error(exc, id, init_attrs)
      new_error = InstantiationError.new(id, init_attrs)
      new_error.set_backtrace(exc.backtrace)
      new_error
    end

    def self.create_error(exc, id)
      new_error = Error.new(exc.message, id)
      new_error.set_backtrace(exc.backtrace)
      new_error
    end

    def self.def_accessor(accessor, on:, to:, delegate: false)
      on.define_singleton_method(:ms_predecessor) { accessor }
      on.define_singleton_method(accessor) { to }
      on.extend(MethodMissingDelegation) if delegate
    end

    # DSL for describing objects schemas
    module ClassMethods
      class << self
        attr_accessor :__mf_assembler_name__
      end

      def self.included(receiver)
        receiver.extend self
      end

      def self.extended(receiver)
        receiver.produces :flatten_structs, :wrapped_structs, :nested_structs
        receiver.extend Helpers
      end

      def wrap(title, base_class: Class.new(Object), init: nil, delegate: false, on_exception: nil, &block)
        wrapped_struct(title, base_class: base_class.include(Exceptional), init: init)
        class_eval(&block)
        Wrapped.new(self, on_exception, delegate).for(title, &block).inject_method
      end

      def nest(title, base_class: Class.new(Object), init: nil, delegate: false, on_exception: nil, &block)
        nested_struct(title, base_class: base_class.include(Exceptional), init: init)
        class_eval(&block)
        Nested.new(self, on_exception, delegate).for(title, &block).inject_method
      end

      def flat(title, base_class: Class.new(Object), init: nil, on_exception: nil, &block)
        flatten_struct(title, base_class: base_class.include(Exceptional), init: init)
        class_eval(&block)
        Flatten.new(self, on_exception).for(title, &block).inject_method
      end

      def on_exception(&block)
        block ? @on_exception = block : @on_exception
      end
    end

    # Copies on_exception callback definition to subclass
    module InheritanceHelpers
      def inherited(subclass)
        super
        subclass.on_exception(&on_exception)
      end
    end

    def self.included(receiver)
      receiver.extend ClassMethods
      receiver.extend InheritanceHelpers
      receiver.on_exception do |e, _result|
        raise e
      end
    end
  end
end
