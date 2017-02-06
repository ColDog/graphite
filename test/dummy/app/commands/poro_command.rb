class PoroCommand < GraphQL::Api::CommandType
  action :perform, returns: {poro: Poro}, args: {name: :string!}

  def perform
    {poro: Poro.new(args[:name])}
  end

end
