require "graphql/api/resolvers/helpers"

module GraphQL::Api
  module Resolvers
    class ModelListQuery
      include Helpers

      def initialize(model)
        @model = model
      end

      def call(obj, args, ctx)
        results = query(ctx, args)

        policy = get_policy(ctx)
        if policy
          # todo: is there a more efficient way of handling this? or should you be able to skip it?
          results.each do |instance|
            return policy.unauthorized(:read, instance, args) unless policy.read?(instance, args)
          end
        end

        results
      end

      def query(ctx, query_args)
        eager_load = []
        children_names = ctx.irep_node.typed_children.values.map(&:keys).flatten
        children_names.each do |child_name|
          eager_load << child_name if @model.reflections.find do |name, association|
            name == child_name && !association.polymorphic?
          end
        end

        results = @model.where(query_args.to_h)
        results = results.eager_load(*eager_load) if eager_load.any?

        results
      end

    end
  end
end
