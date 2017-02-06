module GraphQL::Api
  module Resolvers
    module Helpers

      def key
        @key ||= @model.name.underscore.to_sym
      end

      def policy_class
        @policy_class ||= "#{@model.name}Policy".safe_constantize
      end

      def get_policy(ctx)
        return ctx[:policy][key] if ctx[:policy] && ctx[:policy][key]

        if policy_class
          policy = @policy_class.new(ctx)
          ctx[:policy] ||= {}
          ctx[:policy][key] = policy
          return policy
        end

        false
      end

      def authorized?(action, ctx, instance, args)
        policy = get_policy(ctx)
        policy && check_auth?(action, policy, instance, args)
      end

      def check_auth?(action, policy, instance, args)
        case action
          when :create
            return policy.create?(instance, args)
          when :update
            return policy.update?(instance, args)
          when :destroy
            return policy.destroy?(instance, args)
          when :read
            return policy.read?(instance, args)
          else
            return true
        end
      end

    end
  end
end
