# frozen_string_literal: true

module Hospodar
  module Builder
    # Error for signaling creating error
    class InstantiationError < StandardError
      attr_reader :init_attrs, :step_id

      def initialize(id, init_attrs)
        @init_attrs = init_attrs
        @step_id = id
        super(error_message)
      end

      private

      def error_message
        msg = "Can't create an instance of #{step_id} class"
        msg += "with the folloving attributes: #{init_attrs}" unless init_attrs.empty?
        msg
      end
    end
  end
end
