class BlockedCommand < GraphQL::Api::CommandType
  action :perform, returns: {poro: Poro}, args: {name: :string}

  def perform
    {poro: Poro.new(inputs[:name])}
  end

end
