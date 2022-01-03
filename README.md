# all-gem

all-gem runs various versions of command provided by gem.

It was inspired by [all-ruby](https://github.com/akr/all-ruby).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'all-gem'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install all-gem

## Usage

Example:

```bash
# Execute `rbs --version` command with all installed versions of rbs gem
$ all-gem rbs --version

# Execute `rbs --version` command with all versions of rbs gem
# It installs gems before execution if it is not installed
$ all-gem --remote rbs --version

# Execute `rbs --version` command with all latest major versions of rbs gem
$ all-gem --remote --major rbs --version
```

See the result of `all-gem help`

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pocke/all-gem.
