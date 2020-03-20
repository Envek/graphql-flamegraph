require "graphql/flamegraph/version"
require "graphql/flamegraph/instrumentation"
require "graphql/flamegraph/tracing"

module GraphQL
  module Flamegraph
    class Error < StandardError; end

    def self.use(schema, enabled: true, path: nil)
      return unless enabled

      schema.instrument(:query, Instrumentation.new(path: path))
      schema.use Tracing, trace_scalars: true
    end
  end
end
