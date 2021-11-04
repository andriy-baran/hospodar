# frozen_string_literal: true

module Hospodar
  module Builder
    # Implements nest(&block) strategy in schemas
    class Nested < Wrapped
      def on_planing(receiver)
        execution_plan(receiver, reverse: true, &dsl_block)
      end

      private

      def type
        :nested
      end
    end
  end
end
