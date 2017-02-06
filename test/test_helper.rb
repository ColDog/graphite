# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
$VERBOSE=nil

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../../test/dummy/db/migrate", __FILE__)]
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Rails::TestUnitReporter.executable = 'bin/test'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end


# do test setup
(1..20).each do
  author = Author.create!(name: 'test')
  blog = Blog.create!(name: 'test', content: 'foobar', author: author)
  tag = Tag.create!(name: 'testing')
  BlogTag.create!(blog: blog, tag: tag)

  tag = Tag.create!(name: 'testing2')
  BlogTag.create!(blog: blog, tag: tag)
end

GraphQL::Api.configure do
  model Author
  model BlogTag
  model Tag
  model Blog
  model Poro

  command BlogCommand, action: :update
  command BlogCommand, action: :delete
  command BlogCreateCommand
  command PoroCommand
  command BlockedCommand

  query BlogQuery
  query BlogQuery, action: :secondary
  query BlockedQuery
end
