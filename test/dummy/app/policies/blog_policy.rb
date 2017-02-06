class BlogPolicy < GraphQL::Api::Policy

  def read?(*)
    ctx[:test_key].nil?
  end

  def destroy?(*)
    ctx[:test_key].nil?
  end

  def create?(*)
    ctx[:test_key].nil?
  end

  def update?(*)
    ctx[:test_key].nil?
  end

  def access_field?(object, field)
    field.to_sym != :name
  end

end
