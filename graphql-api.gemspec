$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "graphql/api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "graphql-api"
  s.version     = GraphQL::Api::VERSION
  s.authors     = ["Colin Walker"]
  s.email       = ["colinwalker270@gmail.com"]
  s.homepage    = "https://github.com/coldog/graphql-api"
  s.summary     = "Rails graphql framework."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0", ">= 5.0.0.1"
  s.add_dependency "graphql", "~> 0.19.0"

  s.add_development_dependency "sqlite3"
end
