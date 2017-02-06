require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class Field
      include Helpers

      def initialize(model, name)
        @model = model
        @name = name
      end

      def call(obj, args, ctx)
        params = args.to_h

        policy = get_policy(ctx)
        if policy
          return policy.unauthorized(:read, obj, params) unless policy.read?(obj, params)
          return policy.unauthorized_field_access(@name, obj, params) unless policy.access_field?(obj, @name)
        end

        obj.send(@name)
      end

    end
  end
end
