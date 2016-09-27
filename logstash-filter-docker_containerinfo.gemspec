Gem::Specification.new do |s|
  s.name = 'logstash-filter-docker_containerinfo'
  s.version = '0.1.0'
  s.licenses = ['Apache License (2.0)']
  s.summary = "Resolves Docker container IDs into configurable container-information (like name)."
  s.description = "You can add a specific configurable container-information based on the container-id. The lookup/resolving is cached for performance. Many thanks for inspiration from plugin logstash-filter-docker_container by Geoff Bourne."
  s.authors = ["Alexander Fischer"]
  s.email = 'fischer.alexander@web.de'
  s.homepage = "https://github.com/afischer211/logstash-filter-docker_containerinfo"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.required_ruby_version = '>= 2.0.0'
  s.add_runtime_dependency "logstash-core-plugin-api", ">= 1.60", "<= 2.99"
  s.add_runtime_dependency "docker-api", ">= 1.31.0"
  s.add_development_dependency "logstash-patterns-core"
  s.add_development_dependency "logstash-filter-grok"
  s.add_development_dependency "logstash-devutils"
end
