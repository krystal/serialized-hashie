# frozen_string_literal: true

require 'spec_helper'
require 'serialized_hashie/hash'

RSpec.describe SerializedHashie::Hash do
  context '.dump' do
    after(:each) { SerializedHashie.dump_extensions.reset }

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
    end

    it 'should work with nested hashes' do
      SerializedHashie.dump_extensions.add(:test) { |value| value.is_a?(String) ? value.upcase : value }
      value = described_class.dump({ hello: 'world', nested: { vegetable: 'potato', more_nesting: { fruit: 'banana' } } })
      expect(value).to eq '{"hello":"WORLD","nested":{"vegetable":"POTATO","more_nesting":{"fruit":"BANANA"}}}'
    end

    it 'should work with nested hashes in arrays' do
      SerializedHashie.dump_extensions.add(:test) { |value| value.is_a?(String) ? value.upcase : value }
      value = described_class.dump({ hello: 'world', nested: { vegetables: [{ name: 'potato' }, { name: 'cucumber' }], more_nesting: { fruits: [{ name: 'banana' }, { name: 'apple' }] } } })
      expect(value).to eq '{"hello":"WORLD","nested":{"vegetables":[{"name":"POTATO"},{"name":"CUCUMBER"}],"more_nesting":{"fruits":[{"name":"BANANA"},{"name":"APPLE"}]}}}'
    end
  end

  context '.load' do
    after(:each) do
      SerializedHashie.load_extensions.reset
      SerializedHashie.load_hash_extensions.reset
    end

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
    end

    it 'should work with nested hashes' do
      SerializedHashie.load_extensions.add(:test) { |value| value.is_a?(String) ? value.downcase : nil }
      hash = described_class.load('{"hello":"WORLD","nested":{"vegetable":"POTATO","more_nesting":{"fruit":"BANANA"}}}')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash).to eq({ 'hello' => 'world', 'nested' => { 'vegetable' => 'potato', 'more_nesting' => { 'fruit' => 'banana' } } })
    end

    it 'should work with nested hashes in arrays' do
      SerializedHashie.load_extensions.add(:test) { |value| value.is_a?(String) ? value.downcase : nil }
      hash = described_class.load('{"hello":"WORLD","nested":{"vegetables":[{"name":"POTATO"},{"name":"CUCUMBER"}],"more_nesting":{"fruits":[{"name":"BANANA"},{"name":"APPLE"}]}}}')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash).to eq({ 'hello' => 'world', 'nested' => { 'vegetables' => [{ 'name' => 'potato' }, { 'name' => 'cucumber' }], 'more_nesting' => { 'fruits' => [{ 'name' => 'banana' }, { 'name' => 'apple' }] } } })
    end

    it 'should pass through hashes through their own extensions' do
      SerializedHashie.load_hash_extensions.add(:test) { |hash| hash.transform_keys(&:upcase) }
      hash = described_class.load('{"some_hash":{"name":"Michael"}}')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash).to eq({ 'some_hash' => { 'NAME' => 'Michael' } })
    end

    it 'should pass hashses through their own extension and return non-hash values properly' do
      SerializedHashie.load_hash_extensions.add(:test) { |hash| hash.key?('name') ? hash['name'] : hash }
      hash = described_class.load('{"some_hash":{"name":"Michael"}}')
      expect(hash).to be_a SerializedHashie::Hash
      expect(hash).to be_a Hashie::Mash
      expect(hash).to eq({ 'some_hash' => 'Michael' })
    end
  end
end
