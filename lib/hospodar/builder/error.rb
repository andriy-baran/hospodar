# frozen_string_literal: true

module Hospodar
  module Builder
    # General error that has step ID object
    class Error < StandardError
      attr_reader :step_id

      def initialize(msg, id)
        super(msg)
        @step_id = id
      end
    end
  end
end
