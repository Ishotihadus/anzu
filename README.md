# Anzu

	人生の質を下げてまで、働く必要ないって。自分のために生きなきゃ

A Twitter API wrapper for Ruby.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add anzu

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install anzu

## Usage

```ruby
require 'anzu'

client = Anzu::Client.new do |config|
  config.consumer_key = 'consumer-key'
  config.consumer_secret = 'consumer-secret'
  config.access_token = 'access-token'
  config.access_token_secret = 'access-token-secret'
end

client.create_tweet_v2('tweet from anzu')
```

# License

This gem is provided under the MIT License.
