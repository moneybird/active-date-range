# frozen_string_literal: true

begin
  require "i18n"
  require "i18n/backend/fallbacks"
rescue LoadError => e
  $stderr.puts "The i18n gem is not available. Please add it to your Gemfile and run bundle install"
  raise e
end

I18n.load_path << File.expand_path("locale/en.yml", __dir__)
