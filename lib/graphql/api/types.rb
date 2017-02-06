require "graphql/api/helpers"
require "graphql"

module GraphQL::Api
  module Types
    include Helpers

    # Create the query type for the given model class.
    def model_query_type(model_class, fields: {}, resolver_class: nil)
      object_types = @types

      GraphQL::ObjectType.define do
        name model_class.name
        description "Get #{model_class.name}"

        if model_class.respond_to?(:columns)
          model_class.columns.each do |column|
            field column.name do
              type graphql_type(column)
              resolve resolver_class.new(model_class, column.name)
            end
          end
        end

        if model_class.respond_to?(:fields)
          model_class.fields.each do |field_name, field_type|
            field field_name, graphql_type_of(field_type)
          end
        end

        fields.each do |field_name, field_type|
          field field_name, graphql_type_of(field_type)
        end

        if model_class.respond_to?(:reflections)
          model_class.reflections.each do |name, association|
            association_type = object_types[association.class_name.constantize]
            unless association_type
              raise("Association not found: #{association.class_name}")
            end

            field(name) do
              if association.collection?
                type types[association_type]
              else
                type association_type
              end
              resolve resolver_class.new(model_class, name)
            end
          end
        end

      end
    end

    # Create the create mutation type for the given model class.
    def model_mutation_create_type(model_class, fields: {}, resolver: nil, resolver_class: nil)
      return nil unless model_class < ActiveRecord::Base

      object_types = @types
      resolver = resolver || resolver_class.new(model_class)

      GraphQL::Relay::Mutation.define do
        name "Create#{model_class.name}"
        description "Create #{model_class.name}"

        model_class.columns.each do |column|
          input_field column.name, graphql_type(column)
        end

        if model_class.respond_to?(:fields)
          model_class.fields.each do |field_name, field_type|
            input_field field_name, graphql_type_of(field_type)
          end
        end

        fields.each do |field_name, field_type|
          input_field field_name, graphql_type_of(field_type)
        end

        unless object_types[model_class]
          raise("Return type not found: #{model_class.name}")
        end

        return_field model_class.name.underscore.to_sym, object_types[model_class]
        resolve resolver
      end
    end

    # Create the update mutation type for the given model class.
    def model_mutation_update_type(model_class, fields: {}, resolver: nil, resolver_class: nil)
      return nil unless model_class < ActiveRecord::Base

      object_types = @types
      resolver = resolver || resolver_class.new(model_class)

      GraphQL::Relay::Mutation.define do
        name "Update#{model_class.name}"
        description "Update #{model_class.name}"

        # todo: use model primary key or something else
        input_field :id, !types.ID

        model_class.columns.each do |column|
          input_field column.name, graphql_type(column)
        end

        if model_class.respond_to?(:fields)
          model_class.fields.each do |field_name, field_type|
            input_field field_name, graphql_type_of(field_type)
          end
        end

        fields.each do |field_name, field_type|
          input_field field_name, graphql_type_of(field_type)
        end

        unless object_types[model_class]
          raise("Return type not found: #{model_class.name}")
        end

        return_field model_class.name.underscore.to_sym, object_types[model_class]
        resolve resolver
      end
    end

    # Create the delete mutation type for the given model class.
    def model_mutation_delete_type(model_class, fields: {}, resolver: nil, resolver_class: nil)
      return nil unless model_class < ActiveRecord::Base

      object_types = @types
      resolver = resolver || resolver_class.new(model_class)

      GraphQL::Relay::Mutation.define do
        name "Delete#{model_class.name}"
        description "Delete #{model_class.name}"

        # todo: allow for different primary key
        input_field :id, !types.ID

        unless object_types[model_class]
          raise("Return type not found: #{model_class.name}")
        end

        fields.each do |field_name, field_type|
          input_field field_name, graphql_type_of(field_type)
        end

        return_field model_class.name.underscore.to_sym, object_types[model_class]
        resolve resolver
      end
    end

    # Command mutation.
    def command_mutation_type(object_type, action, resolver: nil, resolver_class: nil)
      object_types = @types
      prefix = action == :perform ? '' : action.capitalize

      resolver = resolver || resolver_class.new(object_type, action)

      GraphQL::Relay::Mutation.define do
        name "#{prefix}#{object_type.name}"
        description "Command #{object_type.name} #{action}"

        object_type.actions[action][:args].each do |input, type|
          input_field input, graphql_type_of(type)
        end

        object_type.actions[action][:returns].each do |return_name, return_type|
          return_field return_name, graphql_type_for_object(return_type, object_types)
        end

        resolve resolver
      end
    end

  end
end
