# frozen_string_literal: true

module Hospodar
  # Singleton that collects generted modudes
  module Factories
    class << self
      def add_module(components_name, **attrs)
        registry.resolve(components_name, **attrs)
      end

      def memoized_modules
        registry.registered_modules
      end

      private

      def build_module
        lambda do |components_name, **attrs|
          ModuleBuilder.call(components_name, **attrs)
        end
      end

      def registry
        @registry ||= Registry.new(on_missing_key: build_module)
      end
    end
  end
end
