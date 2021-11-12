# Graphql::LogHelper

GraphQL is amazing. But one disadvantage is that with Ruby you lose some of the
logging that "just works" with REST. That is, all of the log messages have the
same controller (`API::GraphqlController`) and the params are lost or
unstructured.

This gem aims to make is easy to include this information in logs messages.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphql-log_helper'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install graphql-log_helper

## Getting Started

Add [lograge](https://github.com/roidrage/lograge) to your Gemfile and include
the following in `config/initializers/lograge.rb`—
```ruby
Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
    if event.payload[:controller] == 'GraphqlController'
      Graphql::LogHelper.log_details(event.payload[:params])
    else
      { params: event.payload[:params] }
    end.compact
  end
end
```

## Documentation

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/hoverinc/graphql-log_helper. This project is intended to be
a safe, welcoming space for collaboration, and contributors are expected to
adhere to the
[code of conduct](https://github.com/hoverinc/graphql-log_helper/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Graphql::LogHelper project's codebases, issue
trackers, chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/hoverinc/graphql-log_helper/blob/master/CODE_OF_CONDUCT.md).
