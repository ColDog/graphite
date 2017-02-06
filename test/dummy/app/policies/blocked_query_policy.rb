class BlockedQueryPolicy < GraphQL::Api::QueryPolicy

  def execute?(*)
    false
  end

end
