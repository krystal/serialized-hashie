# Serialized Hashie

This is a library that allows you to serialize a Hashie::Mash object (as JSON) into a database. It also features a couple of extra extensions to allow you to alter how objects are serialized/deserialized.

## Installation

Add this line to your application's Gemfile:

```ruby
source 'https://rubygems.pkg.github.com/krystal' do
  gem 'serialized-hashie', '~> 1.0'
end
```

## Usage

This is designed to be used a serializer for ActiveRecord models.

```ruby
class User < ApplicationRecord
  serialize :properties, SerializedHashie::Hash
end

user = User.new
user.properties.something = 'Hello world!'
user.save

user = User.last
user.properties.something #=> 'Hello world!'
```

### Extensions

The loading & dumping can also be extended to handle how individual entries in any hashes are handled.

```ruby
# Add an extension to dump all stings in uppercase
SerializedHashie.dump_extensions.add(:upcase) do |value|
  value.is_a?(String) ? value.upcase : value
end

# Add a load extension to always return them again in lowercase
SerializedHashie.load_extensions.add(:downcase) do |value|
  value.is_a?(String) ? value.downcase : value
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/krystal/serialized-hashie.
