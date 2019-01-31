$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "franklin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "franklin"
  s.version     = Franklin::VERSION
  s.authors     = ["Gk Parish-Philp"]
  s.email       = ["gk@gkparishphilp.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Franklin."
  s.description = "TODO: Description of Franklin."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.6", ">= 5.1.6.1"

  s.add_development_dependency "sqlite3"
end
