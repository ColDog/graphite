module GraphQL::Api
  class UnauthorizedException < Exception
    attr_accessor :user, :action, :instance, :params

    def initialize(user = nil, action = nil, instance = nil, params = nil)
      @action = action
      @instance = instance
      @params = params
      @user = user
    end

    def as_json
      {
          action: action,
          object: instance.class.name,
      }
    end

  end
end
