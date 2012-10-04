# encoding: UTF-8

Gem::Specification.new do |gem|
  gem.name          = "agent_user"
  gem.version       = "1.0.3"
  gem.authors       = ["Marc Lipovsky"]
  gem.email         = ["marclipovsky@gmail.com"]
  gem.summary       = "A better user agent parser."
  gem.description   = "."
  
  gem.files         = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
end
