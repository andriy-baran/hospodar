# frozen_string_literal: true

class Fine
  def inspect
    '<Fine>'
  end
end

class Good2
  def inspect
    '<Good>'
  end
end

class Best
  def inspect
    '<Best>'
  end
end

RSpec.describe Hospodar do
  describe 'wrap' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          wrap :main, delegate: true do
            element :fine, base_class: Fine
            element :good, base_class: Good2
            element :best, base_class: Best
          end

          good_element do
            def valid?
              false
            end
          end

          fine_element do
            def valid?
              true
            end
          end
        end
      end
    end

    it 'properly organize order of methods calling' do
      res = target.build_main.do_while { |o, _i| o.valid? }.call
      expect(res.valid?).to eq(false)
    end
  end

  describe 'exception handling #1' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          wrap :main, delegate: true do
            element :fine, base_class: Fine, init: ->(_k) { raise('No way') }
            element :good, base_class: Good2
            element :best, base_class: Best
          end

          good_element do
            def valid?
              false
            end
          end

          fine_element do
            def valid?
              true
            end
          end

          on_exception do |_e, res|
            def res.valid?
              false
            end
            nil
          end
        end
      end
    end
    it 'stops assembling and calls on_exception' do
      child = Class.new(target)
      res = child.build_main.call { |o, _i| o.valid? }
      expect(res).to be_exceptional
      expect(res.exception).to be_a(Hospodar::Builder::InstantiationError)
      expect(res.exception.step_id).to have_attributes(title: :fine, group: :element)
      expect(res).to_not respond_to(:fine)
      expect(res).to_not respond_to(:good)
      expect(res).to_not respond_to(:best)
      expect(res).to_not be_valid
    end
  end

  describe 'exception handling #2' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          wrap :main, delegate: true do
            element :fine, base_class: Fine
            element :good, base_class: Good2, init: ->(_k) { raise('No way') }
            element :best, base_class: Best
          end

          good_element do
            def valid?
              false
            end
          end

          fine_element do
            def valid?
              true
            end
          end

          on_exception do |e, res|
            # NOOP
          end
        end
      end
    end
    it 'stops assembling and calls on_exception' do
      res = target.build_main.do_while { |o, _i| o.valid? }.call
      expect(res).to be_exceptional
      expect(res.exception).to be_a(Hospodar::Builder::InstantiationError)
      expect(res.exception.step_id).to have_attributes(title: :good, group: :element)
      expect(res).to respond_to(:fine)
      expect(res).to_not respond_to(:good)
      expect(res).to_not respond_to(:best)
      expect(res).to be_valid
    end
  end

  describe 'exception handling #3' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          wrap :main, delegate: true do
            element :fine, base_class: Fine
            element :good, base_class: Good2
            element :best, base_class: Best
          end

          best_element do
            def valid?
              true
            end
          end

          good_element do
            def valid?
              true
            end
          end

          fine_element do
            def valid?
              true
            end
          end

          on_exception do |_e, _res|
            false
          end
        end
      end
    end

    it 'stops assembling and calls on_exception' do
      res = target.build_main.do_while { |_o, i| i.to_sym == :best_element ? raise('No way') : true }.call
      expect(res).to be_exceptional
      expect(res.exception).to be_a(Hospodar::Builder::Error)
      expect(res.exception.step_id).to have_attributes(title: :best, group: :element)
      expect(res).to respond_to(:fine)
      expect(res).to respond_to(:good)
      expect(res).to respond_to(:best)
      expect(res).to be_valid
    end
  end

  describe 'exception handling #4' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          nest :main, delegate: true, on_exception: :ignore do
            element :fine, base_class: Fine
            element :good, base_class: Good2
            element :best, base_class: Best
          end

          best_element do
            def valid?
              true
            end
          end

          good_element do
            def valid?
              true
            end
          end

          fine_element do
            def valid?
              true
            end
          end
        end
      end
    end

    it 'stops assembling and calls on_exception' do
      res = target.build_main { raise('No way') }.call
      expect(res).to be_exceptional
      expect(res.exception).to be_a(Hospodar::Builder::Error)
      expect(res.exception.step_id).to be_nil
      expect(res).to_not respond_to(:fine)
      expect(res).to_not respond_to(:good)
      expect(res).to_not respond_to(:best)
      expect(res).to_not respond_to(:valid?)
    end
  end

  describe 'exception handling #5' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          nest :main, delegate: true, on_exception: :ignore do
            element :fine, base_class: Fine
            element :good, base_class: Good2
            element :best, base_class: Best
          end

          best_element do
            def valid?
              true
            end
          end

          good_element do
            def valid?
              raise('No way')
            end
          end

          fine_element do
            def valid?
              true
            end
          end
        end
      end
    end

    it 'stops assembling and calls on_exception' do
      child = Class.new(target)
      res = child.build_main.do_while { |o, _i| o.valid? }.call
      expect(res).to_not respond_to(:fine)
      expect(res).to respond_to(:good)
      expect(res).to respond_to(:best)
    end
  end

  describe 'exception handling #6' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          flat :main, on_exception: :halt do
            element :fine, base_class: Fine
            element :good, base_class: Good2
            element :best, base_class: Best
          end

          best_element do
            def valid?
              true
            end
          end

          good_element do
            def valid?
              raise('No way')
            end
          end

          fine_element do
            def valid?
              true
            end
          end

          # on_exception do |e, res|
          #   throw :halt
          # end
        end
      end
    end

    it 'stops assembling and calls on_exception' do
      res = target.build_main.do_while { |o, _i| o.valid? }.call
      expect(res).to be_exceptional
      expect(res.exception).to be_a(Hospodar::Builder::Error)
      expect(res.exception.step_id).to have_attributes(title: :good, group: :element)
      expect(res).to respond_to(:fine)
      expect(res).to respond_to(:good)
      expect(res).to_not respond_to(:best)
    end
  end

  describe 'exception handling #7' do
    vars do
      target! do
        Class.new do
          include Hospodar
          include Hospodar::Builder

          produces :elements

          flat :main, on_exception: :ignore do
            element :fine, base_class: Fine
            element :good, base_class: Good2, init: ->(_k) { raise('No way') }
            element :best, base_class: Best
          end

          best_element do
            def valid?
              true
            end
          end

          good_element do
            def valid?
              raise('No way')
            end
          end

          fine_element do
            def valid?
              true
            end
          end

          # on_exception do |e, res|
          #   # noop
          # end
        end
      end
    end
    it 'stops assembling and calls on_exception' do
      res = target.build_main.do_while { |o, _i| o.valid? }.call
      expect(res).to be_exceptional
      expect(res.exception).to be_a(Hospodar::Builder::InstantiationError)
      expect(res.exception.step_id).to have_attributes(title: :good, group: :element)
      expect(res).to respond_to(:fine)
      expect(res).to_not respond_to(:good)
      expect(res).to respond_to(:best)
    end
  end
end
