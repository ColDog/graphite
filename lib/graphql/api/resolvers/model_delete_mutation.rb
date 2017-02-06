require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelDeleteMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        instance = @model.find(args[:id])

        policy = get_policy(ctx)
        if policy && !policy.destroy?(instance, args)
          return policy.unauthorized(:create, instance, args)
        end

        instance.destroy!
        {key => instance}
      end

    end
  end
end
