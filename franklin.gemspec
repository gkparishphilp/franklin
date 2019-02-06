$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "franklin/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "franklin"
  s.version     = Franklin::VERSION
  s.authors     = ["Gk Parish-Philp", "Michael Ferguson"]
  s.email       = ["gk@gkparishphilp.com"]
  s.homepage    = "http://www.groundswellenterprises.com"
  s.summary     = "LifeMeter as an Engine."
  s.description = "LifeMeter as an Engine."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.2.0"


  s.add_dependency "chronic_duration"
  s.add_dependency "numbers_in_words" # ????
  s.add_dependency "statsample" # ????
  s.add_dependency "unitwise" # ????



end
