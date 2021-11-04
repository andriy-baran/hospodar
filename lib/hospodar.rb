# frozen_string_literal: true

require 'dry/inflector'
require 'hospodar/dsl'
require 'hospodar/group_definition'
require 'hospodar/subclassing_helpers'
require 'hospodar/inheritance_helpers'
require 'hospodar/module_builder'
require 'hospodar/factories'
require 'hospodar/registry'
require 'hospodar/builder'
require 'hospodar/version'

# Global namespace
module Hospodar
  class Error < StandardError; end

  private_constant :GroupDefinition
  private_constant :Factories
  private_constant :SubclassingHelpers
  private_constant :InheritanceHelpers
  private_constant :ModuleBuilder
  private_constant :DSL

  # Defines high level interface
  module ClassMethods
    def produces(*components_names, &block)
      components_names.each do |components_name|
        include Factories.add_module(components_name)
      end
      groups = GroupDefinition.new
      groups.instance_eval(&block) if block
      groups.definitions.each do |components_name, attrs|
        include Factories.add_module(components_name, attrs)
      end
    end
  end

  def self.global_registry_module_id(components_name, base_class: nil, init: nil)
    [components_name, base_class, init].hash
  end

  def self.included(receiver)
    receiver.extend ClassMethods
  end

  def self.inflector
    @inflector ||= Dry::Inflector.new
  end

  def self.registered_modules
    Factories.memoized_modules
  end
end
