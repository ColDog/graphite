require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelCreateMutation
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        instance = @model.new(args.to_h)

        policy = get_policy(ctx)
        if policy && !policy.create?(instance, args)
          return policy.unauthorized(:create, instance, args)
        end

        instance.save!
        {key => instance}
      end

    end
  end
end
