module GraphQL::Api

  class QueryDescription
    attr_accessor :name, :type, :args, :resolver

    def initialize(name, type, args, resolver)
      @name = name
      @type = type
      @args = args
      @resolver = resolver
    end

    def mutation_type?
      false
    end

    def query_type?
      true
    end

    def to_s
      "#<Query #{name} type=#{type.name}>"
    end

  end

end
