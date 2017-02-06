require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class QueryObjectQuery
      include Helpers

      def initialize(query_object, action)
        @model = query_object
        @action = action
      end

      def call(obj, args, ctx)
        query = @model.new(args, ctx)

        policy = get_policy(ctx)
        if policy && !policy.execute?(query, @action, args)
          return policy.unauthorized(@action, query, args)
        end

        query.send(@action)
      end

    end
  end
end
