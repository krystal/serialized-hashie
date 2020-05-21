# frozen_string_literal: true

require 'spec_helper'
require 'serialized_hashie/hash'

RSpec.describe SerializedHashie::Hash do
  context '.dump' do
    it 'should return a JSON string' do
      value = described_class.dump({ hello: 'World' })
      expect(value).to eq '{"hello":"World"}'
    end

    it 'should remove any nil values' do
      value = described_class.dump({ hello: 'World', nilValue: nil })
      expect(value).to eq '{"hello":"World"}'
    end

    it 'should remove empty strings' do
      value = described_class.dump({ hello: 'World', nilValue: '' })
      expect(value).to eq '{"hello":"World"}'
    end

    it 'should not remove false' do
      value = described_class.dump({ hello: 'World', falseValue: false })
      expect(value).to eq '{"hello":"World","falseValue":false}'
    end

    it 'should remove any empty items from top-level arrays' do
      value = described_class.dump({ hello: 'World', array: [nil, 1, 2, '', false] })
      expect(value).to eq '{"hello":"World","array":[1,2,false]}'
    end

    it 'should pass through any extensions that have been added' do
      SerializedHashie.dump_extensions.add(:test) { |value| value.upcase }
      value = described_class.dump({ hello: 'WORLD' })
      expect(value).to eq '{"hello":"WORLD"}'
      SerializedHashie.dump_extensions.reset
    end
  end

  context '.load' do
    it 'should create a Hashie::Mash from the given JSON' do
      hash = described_class.load('{"hello":"world"}')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash['hello']).to eq 'world'
    end

    it 'shuold create an empty Mash if the given value is nil' do
      hash = described_class.load(nil)
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash).to be_empty
    end

    it 'should create an empty Mash if the JSON is an empty string' do
      hash = described_class.load('')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash).to be_empty
    end

    it 'should pass through any extensions that have been added' do
      SerializedHashie.load_extensions.add(:test) { |value| value.upcase }
      hash = described_class.load('{"hello":"world"}')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash['hello']).to eq 'WORLD'
      SerializedHashie.load_extensions.reset
    end
  end
end
