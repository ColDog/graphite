require "graphql/api/version"
require "graphql/api/policy"
require "graphql/api/command_policy"
require "graphql/api/query_policy"
require "graphql/api/command_type"
require "graphql/api/query_type"
require "graphql/api/configure"

module GraphQL
  module Api

    def self.schema(opts={})
      @schema ||= configure_default_schema(opts)
    end

    def self.configure(&block)
      config = GraphQL::Api::Configure.new
      config.instance_eval(&block)
      @schema = config.schema
      @schema
    end

    def self.configure_default_schema(opts)
      config = GraphQL::Api::Configure.new
      config.with_defaults(opts)
      config.schema
    end

  end
end
