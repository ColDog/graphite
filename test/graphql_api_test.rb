require 'test_helper'

class GraphQL::Api::Test < ActiveSupport::TestCase

  def schema
    GraphQL::Api.schema
  end

  def schema_query(query, opts={})
    res = schema.execute(query, context: opts[:context])

    if opts[:should_fail]
      assert_not_nil res['errors'], res
    else
      assert_nil res['errors'], res['errors']
    end

    if opts[:print]
      puts res
    end
    res
  end

  # Models
  test "read blog" do
    schema_query("query { blog(id: #{Blog.first.id}) { id, name } }")
  end

  test "read multiple blogs" do
    schema_query("query { blogs { id, name } }")
  end

  test "read multiple blogs with tags" do
    schema_query("query { blogs { id, name, tags { name } } }")
  end

  test "create a blog" do
    res = schema_query('mutation { createBlog(input: {name: "test", content: "hello", author_id: 2}) { blog { id, name, content } } }')
    assert_not_nil res['data']['createBlog']['blog']['content']
  end

  test "update a blog" do
    schema_query('mutation { updateBlog(input: {id: 1, name: "test"}) { blog { id } } }')
  end

  test "delete a blog" do
    schema_query('mutation { deleteBlog(input: {id: 1}) { blog { id } } }')
  end

  # Commands
  test "mutation command" do
    schema_query('mutation { blogCreateCommand(input: {tags: ["test", "testing"], name: "hello"}) { blog { id, tags { name } } } }')
  end

  test "mutation poro return" do
    schema_query('mutation { poroCommand(input: {name: "foobar"}) { poro { name } } }')
  end

  test "mutation custom action command update" do
    schema_query('mutation { updateBlogCommand(input: {name: "foobar", id: 1}) { blog { name } } }')
  end

  test "mutation custom action command delete" do
    schema_query('mutation { deleteBlogCommand(input: {id: 3}) { blog { id } } }')
  end

  # Queries
  test "query blog failing input" do
    schema_query('query { blogQuery(content_matches: ["name"]) { id, name } }', should_fail: true)
  end

  test "query blogs multiple" do
    schema_query('
      query { blogQuery(reqs: "required") { id, name } }
      query { blogs() { id, name } }
      query { blog(id: 1) { id, name, content } }
    ')
  end

  test "query blog secondary" do
    schema_query('query { secondaryBlogQuery(reqs: "required") { id, name } }')
  end

  test "custom mutation" do
    simple_mutation = GraphQL::Relay::Mutation.define do
      input_field :name, !types.String
      return_field :item, types.String
      resolve -> (obj, args, ctx) {  {item: 'hello'}  }
    end

    config = GraphQL::Api::Configure.new
    mutation = config.graphql_mutation do
      field 'simpleMutation', simple_mutation.field
    end

    schema = GraphQL::Schema.define(query: config.graphql_query, mutation: mutation)
    schema.execute('mutation { simpleMutation(input: {name: "hello"}) { item } }')
  end

  # policy objects
  test "policy object read failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query("query { blogs { id, name, tags { name } } }", context: { test_key: 1 })
    end
  end

  test "policy object create failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { createBlog(input: {name: "test", author_id: 2}) { blog { id } } }', context: { test_key: 1 })
    end
  end

  test "policy object update failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { updateBlog(input: {id: 1, name: "test"}) { blog { id } } }', context: { test_key: 1 })
    end
  end

  test "policy object delete failing" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { deleteBlog(input: {id: 1}) { blog { id } } }', context: { test_key: 1 })
    end
  end

  test "policy object query unauthorized" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('query { blockedQuery() { id } }')
    end
  end

  test "policy object command unauthorized" do
    assert_raises(GraphQL::Api::UnauthorizedException) do
      schema_query('mutation { blockedCommand(input: {name: "foobar"}) { poro { name } } }')
    end
  end

  test "cannot read blog name" do
    data = schema_query("query { blog(id: #{Blog.first.id}) { id, name } }")
    assert_nil data['data']['blog']['name']
  end

end
