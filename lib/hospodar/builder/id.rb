# frozen_string_literal: true

module Hospodar
  module Builder
    Id = Struct.new(:group, :title) do
      def to_s
        to_a.compact.reverse.join('_')
      end

      def to_sym
        to_s.to_sym
      end
    end
  end
end
