# frozen_string_literal: true

module Hospodar
  module Builder
    module Strategies
      Link = Struct.new(:strategy, :delegate) do
        attr_reader :object, :step_id

        def call
          Enumerator.new do |yielder|
            strategy.call.inject(nil) do |object, (title, layer_object, id)|
              @object = layer_object
              @step_id = id
              if title.nil?
                yielder << [layer_object, id]
                next layer_object
              end
              Hospodar::Builder.def_accessor(title, on: layer_object, to: object, delegate: delegate)
              yielder << [layer_object, id]
              layer_object
            end
          end
        end

        def last_step
          step_id.title
        end
      end
    end
  end
end
