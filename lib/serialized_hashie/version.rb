# frozen_string_literal: true

module SerializedHashie

  VERSION_FILE_ROOT = File.expand_path('../../VERSION', __dir__)
  if File.file?(VERSION_FILE_ROOT)
    VERSION = File.read(VERSION_FILE_ROOT).strip.delete_prefix('v')
  else
    VERSION = '0.0.0.dev'
  end

end
