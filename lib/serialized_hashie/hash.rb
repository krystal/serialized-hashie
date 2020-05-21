# frozen_string_literal: true

require 'serialized_hashie'
require 'hashie/mash'
require 'json'

module SerializedHashie
  class Hash < Hashie::Mash

    class << self

      def dump(obj)
        obj = obj.reject { |_, v| blank?(v) }
        obj.each do |key, value|
          if value.is_a?(Array)
            obj[key] = value.reject { |v| blank?(v) }
          end

          obj[key] = SerializedHashie.dump_extensions.run(obj[key])
        end
        obj.to_h.to_json
      end

      def load(raw_hash)
        hash = JSON.parse(presence(raw_hash) || '{}')
        hash.each do |key, value|
          hash[key] = SerializedHashie.load_extensions.run(value)
        end
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

    end

  end
end
