require_relative "lib/ar_searchable/version"

Gem::Specification.new do |spec|
  spec.name        = "ar_searchable"
  spec.version     = ArSearchable::VERSION
  spec.authors     = ["Steve Brown"]
  spec.email       = ["steve@zergsoft.com"]
  spec.summary = "A simple, non-intrusive ActiveRecord search concern"
  spec.description = "Adds numeric, date, string and other scopes only when specified."
  spec.homepage = "https://github.com/jpgeek/ar_searchable"
  spec.license     = "MIT"

  spec.require_paths = ["lib"]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # "allowed_push_host" to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  #spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # spec.files        = Dir['{lib/**/*,[A-Z]*}']
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
    #Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_runtime_dependency 'rails', '~> 7.0', '>= 7.0.4.2'
  spec.add_development_dependency "rspec-rails", '~> 6.0'
end
