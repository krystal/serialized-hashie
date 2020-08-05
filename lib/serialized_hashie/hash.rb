# frozen_string_literal: true

require 'serialized_hashie'
require 'hashie/mash'
require 'json'

module SerializedHashie
  class Hash < Hashie::Mash

    class << self

      def dump(obj)
        hash = dump_hash(obj)
        hash.to_json
      end

      def load(raw_hash)
        hash = JSON.parse(presence(raw_hash) || '{}')
        hash = load_hash(hash)
        new(hash)
      end

      private

      def blank?(value)
        return true if value.nil?
        return true if value.is_a?(String) && value.empty?

        false
      end

      def presence(value)
        blank?(value) ? nil : value
      end

      def dump_hash(hash)
        hash = hash.transform_values do |value|
          dump_value(value)
        end
        hash.reject { |_, v| blank?(v) }
      end

      def dump_value(value)
        if blank?(value)
          return nil
        end

        if value.is_a?(::Hash)
          return dump_hash(value)
        end

        if value.is_a?(::Array)
          return value.map { |v| dump_value(v) }.compact
        end

        SerializedHashie.dump_extensions.run(value)
      end

      def load_hash(hash)
        hash.transform_values do |value|
          load_value(value)
        end
      end

      def load_value(value)
        if value.is_a?(::Hash)
          hash = SerializedHashie.load_hash_extensions.run(value)
          return load_hash(hash)
        end

        return value.map { |v| load_value(v) } if value.is_a?(Array)

        SerializedHashie.load_extensions.run(value)
      end

    end

  end
end
