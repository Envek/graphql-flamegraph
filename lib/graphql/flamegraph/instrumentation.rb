require 'tmpdir'
require "graphql/flamegraph/result"

module GraphQL
  module Flamegraph
    class Instrumentation
      def initialize(path: nil)
        validate_directory!(path) if path
        @path = path
      end

      def before_query(query)
        reset_cache!(query)
      end

      def after_query(query)
        return unless enabled?(query)

        result = Result.new(cache(query))
        query.context[:flamegraph] = result
        return unless @path

        file_path = Dir::Tmpname.create(['graphql-flamegraph-', '.txt'], @path) {}
        File.write(file_path, result.serialize)
        puts <<~MESSAGE
          Check your flamegraph at #{file_path}
          Open it in https://www.speedscope.app/ or in local speedscope:

              speedscope #{file_path}

        MESSAGE
      end

      private

      def enabled?(query)
        !!query.context[:flamegraph]
      end

      def validate_directory!(path)
        return if Dir.exist?(path) && File.writable?(path)

        raise ArgumentError, "Path for graphql-flamegraph must be a writable directory!"
      end

      def cache(query)
        query.context.namespace(GraphQL::Flamegraph)[:field_runtime_cache]
      end

      def reset_cache!(query)
        query.context.namespace(GraphQL::Flamegraph)[:field_runtime_cache] =
          Hash.new { |h,k| h[k] = 0.0 }
      end
    end
  end
end
