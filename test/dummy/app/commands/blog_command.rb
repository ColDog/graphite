class BlogCommand < GraphQL::Api::CommandType
  action :update, returns: {blog: Blog}, args: {name: :string, tags: [:string], id: :integer}
  action :delete, returns: {blog: Blog}, args: {name: :string, tags: [:string], id: :integer}

  def update
    blog = Blog.find(args[:id])
    blog.update!(args.to_h)
    {blog: blog}
  end

  def delete
    blog = Blog.find(args[:id]).destroy!
    {blog: blog}
  end

end
