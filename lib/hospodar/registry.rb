# frozen_string_literal: true

module Hospodar
  # Simple container for modules
  class Registry
    def initialize(on_missing_key:)
      @modules = {}
      @on_missing_key = on_missing_key
    end

    def resolve(components_name, **attrs)
      id = Hospodar.global_registry_module_id(components_name, **attrs)
      find(id) || build(components_name, **attrs)
    end

    def registered_modules
      @modules.values
    end

    private

    def find(module_id)
      @modules[module_id]
    end

    def register(module_instance)
      @modules[module_instance.hash] = module_instance
    end

    def build(components_name, **attrs)
      register(@on_missing_key.call(components_name, **attrs))
    end
  end
end
