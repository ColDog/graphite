module GraphQL::Api
  module Helpers

    def all_constants(root)
      begin
        Dir["#{Rails.root}/app/#{root}/*"].map do |f|
          file = f.split('/')[-1]
          if file.end_with?('.rb')
            const = file.split('.')[0].camelize.constantize
            const unless const.try(:abstract_class)
          end
        end.compact
      rescue
        []
      end
    end

    def graphql_type_for_object(return_type, object_types)
      if return_type.nil?
        raise("Return type is nil for object")
      end

      if return_type.respond_to?(:to_sym) || (return_type.is_a?(Array) && return_type[0].respond_to?(:to_sym))
        type = graphql_type_of(return_type.to_sym)
      elsif return_type.is_a?(Array)
        type = object_types[return_type[0]].to_list_type
      else
        type = object_types[return_type]
      end

      if type.nil?
        raise("Could not parse return type for: #{return_type}")
      end

      type
    end

    def graphql_type_of(type)

      is_required = false
      if type.to_s.end_with?('!')
        is_required = true
        type = type.to_s.chomp('!').to_sym
      end

      is_list = false
      if type.is_a?(Array)
        is_list = true
        type = type[0]
      end

      case type
        when :id
          res = GraphQL::ID_TYPE
        when :integer
          res = GraphQL::INT_TYPE
        when :text
          res = GraphQL::STRING_TYPE
        when :string
          res = GraphQL::STRING_TYPE
        when :decimal
          res = GraphQL::FLOAT_TYPE
        when :float
          res = GraphQL::FLOAT_TYPE
        when :boolean
          res = GraphQL::BOOLEAN_TYPE
        else
          res = GraphQL::STRING_TYPE
      end

      res = res.to_list_type if is_list
      res = !res if is_required

      res
    end

    def graphql_type(column)
      graphql_type_of(column.type)
    end

  end
end
