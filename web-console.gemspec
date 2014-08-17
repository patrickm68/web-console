$:.push File.expand_path("../lib", __FILE__)

require "web_console/version"

Gem::Specification.new do |s|
  s.name     = "web-console"
  s.version  = WebConsole::VERSION
  s.authors  = ["Genadi Samokovarov", "Guillermo Iguaran", "Ryan Dao"]
  s.email    = ["gsamokovarov@gmail.com", "guilleiguaran@gmail.com", "daoduyducduong@gmail.com"]
  s.homepage = "https://github.com/rails/web-console"
  s.summary  = "Rails Console on the Browser."
  s.license  = 'MIT'

  s.files      = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.markdown"]
  s.test_files = Dir["test/**/*"]

  rails_version = "~> 4.0"

  s.add_dependency "railties",        rails_version
  s.add_dependency "activemodel",     rails_version
  s.add_dependency "sprockets-rails", "~> 2.0"
  s.add_dependency "binding_of_caller"

  # We need those for the testing application to run.
  s.add_development_dependency "actionmailer", rails_version
  s.add_development_dependency "activerecord", rails_version
end
