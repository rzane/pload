source 'https://rubygems.org'

# Specify your gem's dependencies in pload.gemspec
gemspec

gem 'pry'

ar_version = ENV.fetch('AR', 5)
gem 'activerecord', "~> #{ar_version}"

# bullet is a little asshole and also monkey patches `reader`.
# adding this to test compatability
gem 'bullet'
