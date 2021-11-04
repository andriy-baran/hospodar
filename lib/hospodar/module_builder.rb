# frozen_string_literal: true

module Hospodar
  # Generates module that adds support for objects creation
  class ModuleBuilder < Module
    private_class_method :new

    # Sets up factory module properties
    module Setup
      def self.extended(receiver)
        class << receiver
          attr_accessor :component_name, :components_name,
                        :default_base_class, :default_init
        end
      end

      def included(receiver)
        receiver.extend self
      end

      def extended(receiver)
        receiver.extend SubclassingHelpers
        receiver.extend InheritanceHelpers
        receiver.private_class_method :mother_ship_define_init
        receiver.private_class_method :mother_ship_patch_class
        receiver.private_class_method :mother_ship_check_inheritance!
        receiver.private_class_method :mother_ship_included_modules
        receiver.private_class_method :mother_ship_copy_configuration_for_unit
        receiver.private_class_method :mother_ship_activate_components_for_factory
      end

      def hash
        Hospodar.global_registry_module_id(components_name,
                                           base_class: default_base_class,
                                           init: default_init)
      end

      def components_storage_name(title = components_name)
        :"mother_ship_#{title}"
      end

      def simple_store_method_name(name)
        reader = component_class_reader(name)
        :"simple_store_#{reader}_class"
      end

      def store_method_name(name)
        :"#{component_class_reader(name)}="
      end

      def activation_method_name(title = component_name)
        :"activate_#{title}_component"
      end

      def new_instance_method_name(title)
        :"new_#{title}_#{component_name}_instance"
      end

      def component_class_reader(title)
        :"#{title}_#{component_name}_class"
      end

      def configure_component_method_name(title)
        :"#{title}_#{component_name}"
      end
    end

    private_constant :Setup

    def self.inflector
      Hospodar.inflector
    end

    def self.call(components_name, **attrs)
      new.tap do |mod|
        mod.extend Setup
        mod.components_name = components_name
        mod.component_name = inflector.singularize(components_name).to_sym
        mod.default_base_class = attrs[:base_class]
        mod.default_init = attrs[:init]
        mod.extend DSL
        mod.define_components_registry
        mod.define_component_adding_method
        mod.define_component_activation_method
      end
    end
  end
end
