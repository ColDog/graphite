require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class CommandMutation
      include Helpers

      def initialize(command, action)
        @model = command
        @action = action
      end

      def call(obj, args, ctx)
        cmd = @model.new(args, ctx)

        policy = get_policy(ctx)
        if policy && !policy.perform?(cmd, @action, args)
          return policy.unauthorized(@action, cmd, args)
        end

        cmd.send(@action)
      end

    end
  end
end
