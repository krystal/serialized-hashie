# frozen_string_literal: true

require 'serialized_hashie/version'
require 'serialized_hashie/hash'
require 'serialized_hashie/extensions'

module SerializedHashie

  class Error < StandardError
  end

  class << self

    def load_extensions
      @load_extensions ||= Extensions.new
    end

    def dump_extensions
      @dump_extensions ||= Extensions.new
    end

  end

end
