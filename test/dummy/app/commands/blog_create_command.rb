class BlogCreateCommand < GraphQL::Api::CommandType
  action :perform, returns: {blog: Blog}, args: {name: :string, tags: [:string]}

  def perform
    blog = Blog.create!(name: args[:name], author_id: Author.first.id)
    (args[:tags] || []).each do |tag|
      t = Tag.find_or_create_by!(name: tag)
      blog.blog_tags.create!(tag_id: t.id)
    end

    {blog: blog}
  end

end
