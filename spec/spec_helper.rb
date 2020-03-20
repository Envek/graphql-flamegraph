require "bundler/setup"
require "graphql/flamegraph"
require "pry"
require "yaml"

TESTING_GRAPHQL_RUBY_INTERPRETER =
  begin
    env_value = ENV["GRAPHQL_RUBY_INTERPRETER"]
    env_value ? YAML.safe_load(env_value) : false
  end

require_relative "support/graphql_schema"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Kernel.srand config.seed
  config.order = :random
end
