class BlockedCommandPolicy < GraphQL::Api::CommandPolicy

  def perform?(*)
    false
  end

end
