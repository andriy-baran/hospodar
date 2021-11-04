# frozen_string_literal: true

module Hospodar
  module Builder
    # Adds integration for exceptions handling
    module Exceptional
      def self.included(received)
        received.send(:attr_accessor, :exception, :on_exception)
      end

      def ignore_exceptions?
        on_exception == :ignore
      end

      def exceptional?
        !exception.nil?
      end
    end
  end
end
