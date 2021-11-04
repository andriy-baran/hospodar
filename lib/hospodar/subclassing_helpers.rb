# frozen_string_literal: true

module Hospodar
  # Component-level logic for patching base classes
  module SubclassingHelpers
    def mother_ship_define_init(klass, &init)
      if init
        klass.define_singleton_method(:__ms_init__, &init)
      elsif klass.superclass.respond_to?(:__ms_init__)
        parent_init = klass.superclass.method(:__ms_init__)
        klass.define_singleton_method(:__ms_init__, &parent_init)
      else
        default_init = ->(c, *attrs, &block) { c.new(*attrs, &block) }
        klass.define_singleton_method(:__ms_init__, &default_init)
      end
    end

    def mother_ship_patch_class(base_class, &block)
      return base_class unless block

      Class.new(base_class, &block)
    end

    def mother_ship_check_inheritance!(component_class, base_class)
      return if component_class.nil? || base_class.nil?
      raise(ArgumentError, "must be a subclass of #{base_class.inspect}") unless component_class <= base_class
    end
  end
end
