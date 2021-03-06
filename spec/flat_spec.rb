# frozen_string_literal: true

RSpec.describe Hospodar do
  vars do
    target! do
      Class.new do
        include Hospodar
        include Hospodar::Builder

        produces :inputs, :outputs, :stages

        flat :main, base_class: Class.new {
                                  def to_s
                                    'main'
                                  end
                                } do
          input :zero, init: ->(klass, x = 1, y = 2) { klass.new(x, y) }
          stage :four
          stage :one
          stage :two
          stage :three
          output :ten
        end

        zero_input do
          attr_reader :x, :y

          def initialize(x, y)
            @x = x
            @y = y
          end

          def a
            'a'
          end
        end
        four_stage do
          def b
            'b'
          end
        end
        one_stage do
          def c
            'c'
          end
        end
        two_stage do
          def d
            'd'
          end
        end
        three_stage do
          def e
            'e'
          end
        end
        ten_output do
          def f
            'f'
          end
        end
        main_flatten_struct do
          def res
            'res'
          end
        end
      end
    end
  end

  it { expect(target).to respond_to(:hospodar_inputs) }
  it { expect(target).to respond_to(:hospodar_outputs) }
  it { expect(target).to respond_to(:hospodar_stages) }
  it { expect(target).to respond_to(:one_stage_class) }
  it { expect(target).to respond_to(:two_stage_class) }
  it { expect(target).to respond_to(:three_stage_class) }
  it { expect(target).to respond_to(:four_stage_class) }
  it { expect(target).to respond_to(:zero_input_class) }
  it { expect(target).to respond_to(:ten_output_class) }
  it { expect(target).to respond_to(:main_flatten_struct_class) }
  it { expect(target).to respond_to(:build_main) }

  describe '.assemble_*_struct' do
    it 'returns resulted objects composition' do
      res = target.build_main.call
      expect(res).to respond_to(:ten)
      expect(res).to respond_to(:three)
      expect(res).to respond_to(:four)
      expect(res).to respond_to(:one)
      expect(res).to respond_to(:zero)
      expect(res).to respond_to(:two)
      expect(res).to be_an_instance_of(target.main_flatten_struct_class)
      expect(res.ten).to be_an_instance_of(target.ten_output_class)
      expect(res.three).to be_an_instance_of(target.three_stage_class)
      expect(res.four).to be_an_instance_of(target.four_stage_class)
      expect(res.one).to be_an_instance_of(target.one_stage_class)
      expect(res.zero).to be_an_instance_of(target.zero_input_class)
      expect(res.two).to be_an_instance_of(target.two_stage_class)
    end

    it 'patches original classes' do
      res = target.build_main.call
      expect(res.zero.a).to eq 'a'
      expect(res.zero.x).to eq 1
      expect(res.zero.y).to eq 2
      expect(res.four.b).to eq 'b'
      expect(res.one.c).to eq 'c'
      expect(res.two.d).to eq 'd'
      expect(res.three.e).to eq 'e'
      expect(res.ten.f).to eq 'f'
      expect(res.res).to eq 'res'
      expect(res.to_s).to eq 'main'
    end

    context 'when break proc and after creation proc provided' do
      it 'returns enumerator with created objects' do
        plan = target.build_main { |b| b.zero_input(3, 4) }
        res = plan.do_until { |_o, i| i.to_sym == :one_stage }.call
        expect(res.zero.x).to eq 3
        expect(res.zero.y).to eq 4
        expect { res.two }.to raise_error(NoMethodError)
        expect { res.three }.to raise_error(NoMethodError)
        expect { res.ten }.to raise_error(NoMethodError)
        expect(res.one.c).to eq 'c'
      end
    end
  end

  context 'double inheritance' do
    vars do
      child do
        Class.new(target) do
          ten_output do
            def f
              'g'
            end
          end
        end
      end
      child_of_child do
        Class.new(child) do
          main_flatten_struct do
            def to_s
              'main2'
            end
          end
        end
      end
    end

    describe '.assemble_*_struct' do
      it 'returns resulted objects composition' do
        obj = OpenStruct.new(h: 'h')
        res = child_of_child.build_main(object: obj, title: :init).call
        expect(res).to respond_to(:init)
        expect(res).to respond_to(:ten)
        expect(res).to respond_to(:three)
        expect(res).to respond_to(:four)
        expect(res).to respond_to(:one)
        expect(res).to respond_to(:zero)
        expect(res).to respond_to(:two)
        expect(res.init).to eq(obj)
        expect(res.ten).to be_an_instance_of(child.ten_output_class)
        expect(res.three).to be_an_instance_of(target.three_stage_class)
        expect(res.four).to be_an_instance_of(target.four_stage_class)
        expect(res.one).to be_an_instance_of(target.one_stage_class)
        expect(res.zero).to be_an_instance_of(target.zero_input_class)
        expect(res.two).to be_an_instance_of(target.two_stage_class)
      end

      it 'patches original classes' do
        obj = OpenStruct.new(h: 'h')
        res = child_of_child.build_main(object: obj, title: :init).call
        expect(res.zero.x).to eq 1
        expect(res.zero.y).to eq 2
        expect(res.zero.a).to eq 'a'
        expect(res.four.b).to eq 'b'
        expect(res.one.c).to eq 'c'
        expect(res.two.d).to eq 'd'
        expect(res.three.e).to eq 'e'
        expect(res.ten.f).to eq 'g'
        expect(res.init.h).to eq 'h'
        expect(res.res).to eq 'res'
        expect(res.to_s).to eq 'main2'
      end

      context 'when break proc and after creation proc provided' do
        it 'returns enumerator with created objects' do
          plan = child_of_child.build_main { |b| b.zero_input(3, 4) }
          res = plan.do_until { |_o, i| i.to_sym == :one_stage }.call
          expect(res.zero.x).to eq 3
          expect(res.zero.y).to eq 4
          expect { res.two }.to raise_error(NoMethodError)
          expect { res.three }.to raise_error(NoMethodError)
          expect { res.ten }.to raise_error(NoMethodError)
          expect(res.one.c).to eq 'c'
        end
      end

      context 'when input is breaks the flow' do
        it 'does something' do
          obj = OpenStruct.new(h: 'h', valid?: false)
          res = child_of_child.build_main(object: obj, title: :init).do_while { |o, _| o.valid? }.call
          expect(res).to respond_to(:init)
          expect(res).to_not respond_to(:ten)
          expect(res).to_not respond_to(:three)
          expect(res).to_not respond_to(:four)
          expect(res).to_not respond_to(:one)
          expect(res).to_not respond_to(:zero)
          expect(res).to_not respond_to(:two)
        end
      end
    end
  end
end
