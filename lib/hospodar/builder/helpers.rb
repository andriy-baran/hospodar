# frozen_string_literal: true

module Hospodar
  module Builder
    # Helps determine object creation procedure for given attributes
    module Helpers
      def hospodar_assembler_new_instance(group, step, *_attrs)
        return public_send(:"build_#{step}") if %i[flat wrap nest].include?(group)

        mod = included_modules.detect { |m| m.respond_to?(:component_name) && m.component_name == group }
        return if mod.nil?

        init_method = public_send(mod.component_class_reader(step)).method(:__ms_init__)
        return method(mod.new_instance_method_name(step)) if init_method.arity < 2

        create_method = method(mod.new_instance_method_name(step))
        create_method.curry(create_method.arity.abs)
      end
    end
  end
end
