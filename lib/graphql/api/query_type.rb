module GraphQL::Api
  class QueryType
    attr_accessor :ctx, :args

    def initialize(args, ctx)
      @args = args
      @ctx = ctx
    end

    def self.actions
      @actions ||= {}
    end

    def self.action(action, returns: nil, args: {})
      raise("Query should return a single type") if returns.is_a?(Hash)
      actions[action] = {returns: returns, args: args}
    end

    def current_user
      @ctx[:current_user]
    end

    def arguments
      @args
    end

  end
end
