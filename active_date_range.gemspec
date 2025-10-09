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
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.2.0")

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

  spec.add_runtime_dependency "activesupport", "~> 8.0"
  spec.add_runtime_dependency "i18n", "~> 1.6"

  spec.add_development_dependency "rubocop", "~> 1.18"
  spec.add_development_dependency "rubocop-packaging", "~> 0.6"
  spec.add_development_dependency "rubocop-performance", "~> 1.26"
  spec.add_development_dependency "rubocop-rails", "~> 2.33"
  spec.add_development_dependency "activemodel", "~> 8.0"
end
