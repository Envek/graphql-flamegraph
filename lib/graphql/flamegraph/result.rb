module GraphQL
  module Flamegraph
    class Result
      attr_reader :raw

      def initialize(raw)
        @raw = raw
      end

      def serialize
        raw.map { |k, v| "#{k.join(';')} #{v.to_i}\n" }.join
      end
      alias_method :to_s, :serialize
    end
  end
end
