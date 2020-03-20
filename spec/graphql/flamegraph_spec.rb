RSpec.describe GraphQL::Flamegraph do
  it "has a version number" do
    expect(GraphQL::Flamegraph::VERSION).not_to be nil
  end

  subject do
    GraphQLSchema.execute(
      query: query,
      context: context,
      variables: {},
    )
  end

  let(:query) do
    <<~GRAPHQL
      query {
        products {
          id title price { amount currency }
        }
        users {
          id name
        }
      }
    GRAPHQL
  end

  let(:context) do
    { flamegraph: true }
  end

  it "measures field executions" do
    result = subject
    expect(result.context[:flamegraph].raw).to include(
      ["execute_field", "products", 0, "title"] => be > 1000,
      ["execute_field", "products", 1, "title"] => be > 1_000,
      ["execute_field_lazy", "products", 0, "price"] => be > 10_000,
      ["execute_field_lazy", "products", 1, "price"] => be < 10_000,
    )
  end

  context "when disabled per query" do
    let(:context) do
      {}
    end

    it "does nothing" do
      result = subject
      expect(result.context[:flamegraph]).to be_nil
    end
  end
end
