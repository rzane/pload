$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pload'
require 'pry'
require 'active_record'
require 'bullet'
require_relative 'support/schema'

# Test that my monkey-patching plays nicely with theirs!
Bullet.enable = true
Bullet.raise = false
Pload.raise_errors!

ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['LOG']

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.default_formatter = 'doc' if config.files_to_run.one?
  config.order = :random
end
