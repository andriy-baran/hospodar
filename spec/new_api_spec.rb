# frozen_string_literal: true

CustomType = Class.new(Struct.new(:id))
RSpec.describe Hospodar do
  vars do
    target! do
      Class.new do
        include Hospodar

        produces :inputs, :outputs do
          parts base_class: CustomType, init: ->(k, id) { k.new(id) }
        end

        input :one
        input :two
        part :one

        one_part do
          def triple
            id * 3
          end
        end
      end
    end
  end

  it { expect(target).to respond_to(:hospodar_inputs) }
  it { expect(target).to respond_to(:hospodar_outputs) }
  it { expect(target).to respond_to(:hospodar_parts) }

  it 'has inputs list' do
    expect(target.hospodar_inputs).to match({ one: be_a(Class), two: be_a(Class) })
  end

  it 'has outputs list' do
    expect(target.hospodar_outputs).to eq({})
  end

  it 'sets default base_class for a group' do
    expect(target.one_part_class.superclass).to eq CustomType
  end

  it 'sets default init for a group' do
    part = target.new_one_part_instance(3)
    expect(part.triple).to eq 9
  end
end
