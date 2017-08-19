$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "act_as_permission_controllable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "act_as_permission_controllable"
  s.version     = ActAsPermissionControllable::VERSION
  s.authors     = ["Cai Guanhao (Choi Goon-ho)"]
  s.email       = ["caiguanhao@gmail.com"]
  s.homepage    = "https://github.com/caiguanhao/act_as_permission_controllable"
  s.summary     = "Control user / admin permissions with cancancan."
  s.description = "Easily integrate cancancan into your application with permission control of every controller action."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0", ">= 5.0.0"
  s.add_dependency "cancancan", "~> 1.10"

  s.add_development_dependency "pg", "~> 0.21.0"
end
