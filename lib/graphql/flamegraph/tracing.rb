require "graphql/tracing/platform_tracing"

module GraphQL
  module Flamegraph
    class Tracing < ::GraphQL::Tracing::PlatformTracing

      self.platform_keys = {
        'lex' => "graphql.lex",
        'parse' => "graphql.parse",
        'validate' => "graphql.validate",
        'analyze_query' => "graphql.analyze",
        'analyze_multiplex' => "graphql.analyze",
        'execute_multiplex' => "graphql.execute",
        'execute_query' => "graphql.execute",
        'execute_query_lazy' => "graphql.execute",
        'execute_field' => "graphql.execute",
        'execute_field_lazy' => "graphql.execute"
      }

      def platform_trace(_platform_key, key, data, &block)
        start = ::Process.clock_gettime ::Process::CLOCK_MONOTONIC, :microsecond
        result = block.call
        duration = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC, :microsecond) - start

        case key
        when "lex", "parse"
          # No access to query context here to write results into :-(
          # See https://graphql-ruby.org/api-doc/1.10.5/GraphQL/Tracing
        when "execute_query", "execute_query_lazy"
          # Nothing useful for us as they already includes timings for fields
        when "validate", "analyze"
          context = data[:query].context
          cache(context)[[key]] = duration
        when "execute_field", "execute_field_lazy"
          _field, path, query = extract_field_trace_data(data)
          cache = cache(query.context)
          cache[[key] + path] += duration
        when "authorized", "authorized_lazy", "resolve_type", "resolve_type_lazy"
          cache(data[:context])[[key] + data[:path]] = duration
        end

        result
      end

      # See https://graphql-ruby.org/api-doc/1.10.5/GraphQL/Tracing
      def extract_field_trace_data(data)
        if data[:context] # Legacy non-interpreter mode
          [data[:context].field, data[:context].path, data[:context].query]
        else # Interpreter mode
          data.values_at(:field, :path, :query)
        end
      end

      def cache(context)
        context.namespace(GraphQL::Flamegraph)[:field_runtime_cache]
      end

      # graphql-ruby require us to declare these

      def platform_field_key(type, field)
        "#{type.graphql_name}.#{field.graphql_name}"
      end

      def platform_authorized_key(type)
        "#{type.graphql_name}.authorized"
      end

      def platform_resolve_type_key(type)
        "#{type.graphql_name}.resolve_type"
      end
    end
  end
end
