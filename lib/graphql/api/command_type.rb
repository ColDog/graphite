module GraphQL::Api
  class CommandType
    attr_accessor :ctx, :args

    def initialize(args, ctx)
      @args = args
      @ctx = ctx
    end

    def self.actions
      @actions ||= {}
    end

    def self.action(action, returns: {}, args: {})
      actions[action] = {returns: returns, args: args}
    end

    def current_user
      @ctx[:current_user]
    end

    def inputs
      @args
    end

    def arguments
      @args
    end

  end
end
