# frozen_string_literal: true

require_relative "lib/active_date_range/version"

Gem::Specification.new do |spec|
  spec.name          = "active_date_range"
  spec.version       = ActiveDateRange::VERSION
  spec.authors       = ["Edwin Vlieg"]
  spec.email         = ["edwin@moneybird.com"]

  spec.summary       = "DateRange for ActiveSupport"
  spec.description   = "ActiveDateRange provides a range of dates with a powerful API to manipulate and use date ranges in your software."
  spec.homepage      = "https://github.com/moneybird/active-date-range"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/moneybird/active-date-range"
  spec.metadata["changelog_uri"] = "https://github.com/moneybird/active-date-range/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", "~> 6.1"
  spec.add_dependency "i18n"

  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-packaging"
  spec.add_development_dependency "rubocop-performance"
  spec.add_development_dependency "rubocop-rails"
  spec.add_development_dependency "activemodel"
end
