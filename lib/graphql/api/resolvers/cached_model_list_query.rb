require "graphql/api/resolvers/helpers"
require "graphql/api/resolvers/model_list_query"

module GraphQL::Api
  module Resolvers
    class CachedModelListQuery < ModelListQuery
      include Helpers

      def call(obj, args, ctx)
        query_args = args.to_h
        policy = get_policy(ctx)

        max_updated = @model.where(query_args).max(:updated_at)
        user_id = policy ? policy.user.try(:id) : nil
        key = "#{@model.name}-list-#{user_id}-#{max_updated.to_i}-#{query_args.to_query}"

        results = Rails.cache.fetch(key) { query(query_args) }

        if policy
          # todo: is there a more efficient way of handling this? or should you be able to skip it?
          results.each do |instance|
            return policy.unauthorized(:read, instance, query_args) unless policy.read?(instance, query_args)
          end
        end

        results
      end

    end
  end
end
