class BlockedQuery < GraphQL::Api::QueryType
  action :execute, returns: [Blog], args: {name: :string}

  def execute
    Blog.all
  end

end
