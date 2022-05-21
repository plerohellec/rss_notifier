# frozen_string_literal: true

require_relative "lib/rss_notifier/version"

Gem::Specification.new do |spec|
  spec.name = "rss_notifier"
  spec.version = RssNotifier::VERSION
  spec.authors = ["Philippe Le Rohellec"]
  spec.email = ["philippe@lerohellec.com"]

  spec.summary = "Parse RSS feeds and push notification"
  spec.description = "Parse RSS feeds and push notification."
  # spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "rss"
  spec.add_dependency "awesome_print"
  spec.add_dependency "curb"

  spec.add_development_dependency "solargraph"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
