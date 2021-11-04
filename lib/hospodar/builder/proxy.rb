# frozen_string_literal: true

module Hospodar
  module Builder
    # User accessible objects for firing up building process
    class Proxy
      def initialize(target)
        @target = target
        @condition = {}
      end

      def call
        return @target.call if @condition.empty?

        type, block = @condition.to_a.first
        @target.call(type, &block)
      end

      def do_while(&block)
        return if @condition.one?

        @condition[:do_while] = block
        self
      end

      def do_until(&block)
        return if @condition.one?

        @condition[:do_until] = block
        self
      end
    end
  end
end
