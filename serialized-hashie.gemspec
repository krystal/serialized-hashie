# frozen_string_literal: true

require_relative 'lib/serialized_hashie/version'

Gem::Specification.new do |spec|
  spec.name          = 'serialized-hashie'
  spec.version       = SerializedHashie::VERSION
  spec.authors       = ['Adam Cooke']
  spec.email         = ['adam@krystal.uk']
  spec.summary       = 'Helpers to serialize data into ActiveRecord models as JSON and returning a Hashie::Mash'
  spec.description   = spec.summary
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')
  spec.licenses = ['MIT']
  spec.homepage = 'https://github.com/krystal/serialized-hashie'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features)\//) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(/^exe\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'appraisal', '~> 2.3'

  spec.add_runtime_dependency 'hashie', '>= 4.0', '< 5.0'
  spec.add_runtime_dependency 'json', '>= 1.8', '< 3.0'
end
