require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelFindQuery
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        instance = @model.find_by!(args.to_h)

        policy = get_policy(ctx)
        if policy && !policy.read?(instance, args)
          return policy.unauthorized(:read, instance, args)
        end

        instance
      end

    end
  end
end
