require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelUpdateMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        instance = @model.find(args[:id])

        policy = get_policy(ctx)
        if policy && !policy.update?(instance, args)
          return policy.unauthorized(:update, instance, args)
        end

        instance.update!(args.to_h)
        {key => instance}
      end

    end
  end
end
