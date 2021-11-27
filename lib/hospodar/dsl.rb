# frozen_string_literal: true

module Hospodar
  # Core logic for creating objects
  module DSL
    def define_component_store_method(receiver, title)
      mod = self
      receiver.define_singleton_method(mod.store_method_name(title)) do |klass|
        base_class = public_send(:"#{mod.components_storage_name}")[title]
        hospodar_check_inheritance!(klass, base_class)
        send(mod.simple_store_method_name(title), klass)
      end
    end

    def define_component_simple_store_method(receiver, title)
      mod = self
      receiver.define_singleton_method(mod.simple_store_method_name(title)) do |klass|
        send(:"write_#{mod.component_class_reader(title)}", klass)
        public_send(:"#{mod.components_storage_name}")[title] = klass
      end
      receiver.private_class_method mod.simple_store_method_name(title)
    end

    def define_component_activation_method
      mod = self
      define_method(mod.activation_method_name) do |title, base_class, klass, init = nil, &block|
        raise(ArgumentError, 'please provide a block or class') if klass.nil? && block.nil?

        hospodar_check_inheritance!(klass, base_class)

        target_class = klass || base_class

        patched_class = hospodar_patch_class(target_class, &block)
        hospodar_define_init(patched_class, &init)
        public_send(mod.store_method_name(title), patched_class)
      end
    end

    def define_component_new_instance_method(title)
      mod = self
      define_method mod.new_instance_method_name(title) do |*args|
        klass = public_send(mod.component_class_reader(title))
        klass.__ms_init__(klass, *args)
      end
    end

    def define_component_configure_method(title)
      mod = self
      define_method mod.configure_component_method_name(title) do |klass = nil, init: nil, &block|
        base_class = public_send(:"#{mod.component_class_reader(title)}")
        public_send(mod.activation_method_name, title, base_class, klass, init, &block)
      end
      private mod.configure_component_method_name(title)
    end

    def define_component_adding_method
      mod = self
      define_method(component_name) do |title, base_class: nil, init: nil|
        singleton_class.class_eval do
          reader_name = mod.component_class_reader(title)
          attr_accessor reader_name
          alias_method :"write_#{reader_name}", :"#{reader_name}="
          private :"write_#{reader_name}"
        end
        klass = base_class || mod.default_base_class || Class.new(Object)
        hospodar_define_init(klass, &(init || mod.default_init))
        mod.define_component_store_method(self, title)
        mod.define_component_simple_store_method(self, title)
        send(mod.simple_store_method_name(title), klass)
        mod.define_component_configure_method(title)
        mod.define_component_new_instance_method(title)
      end
    end

    def define_components_registry
      mod = self
      module_eval <<-METHOD, __FILE__, __LINE__ + 1
	      def #{mod.components_storage_name}       # def parts
	        @#{mod.components_storage_name} ||= {} #   @parts ||= {}
	      end                                      # end
      METHOD
    end
  end
end
