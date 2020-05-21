# frozen_string_literal: true

require 'spec_helper'
require 'serialized_hashie/extensions'

RSpec.describe SerializedHashie::Extensions do
  subject(:extensions) { described_class.new }

  context '#add' do
    it 'should add a new extension' do
      extensions.add(:test) { 1 }
      added = extensions.instance_variable_get('@extensions')
      expect(added[:test]).to be_a Proc
      expect(added[:test].call).to eq 1
    end

    it 'should raise an error if an extension with a given name is already defined' do
      extensions.add(:test) { 1 }
      expect do
        extensions.add(:test) { 2 }
      end.to raise_error SerializedHashie::Error, /already defined/
    end
  end

  context '#run' do
    it 'should run through all extensions' do
      extensions.add(:upcase) { |v| v.upcase }
      extensions.add(:exclaim) { |v| v.to_s + '!!!' }
      expect(extensions.run('hello')).to eq 'HELLO!!!'
    end
  end

  context '#has?' do
    it 'should return true if the extension has been added' do
      extensions.add(:upcase) { |v| v.upcase }
      expect(extensions.has?(:upcase)).to be true
    end

    it 'should return false if no extension exists' do
      expect(extensions.has?(:upcase)).to be false
    end
  end
end
