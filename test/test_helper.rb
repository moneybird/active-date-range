# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "active_date_range"
require "active_support"

require "minitest/autorun"

Time.zone = "UTC"

I18n.backend.store_translations(
  "en",
  date: {
    formats: {
      abbr_explicit_day_month: "%b %d",
      abbr_explicit_month: "%B",
      abbr_long_day_month: "%B %d",
      abbr_long_month: "%B",
      abbr_short_day_month: "%b %d",
      abbr_short_month: "%b",
      default: "%Y-%m-%d",
      explicit_day: "%b %d, %Y",
      explicit_day_month: "%b %d, %Y",
      explicit_month: "%B %Y",
      explicit_year: "%B %Y",
      long: "%B %d, %Y",
      long_day: "%B %d, %Y",
      long_day_month: "%B %d, %Y",
      long_month: "%B %Y",
      month: "%B",
      short: "%b %d",
      short_day: "%b %d, %Y",
      short_day_month: "%b %d, %Y",
      short_month: "%b %Y",
      short_year: "%y"
    },
    relative_range: {
      next_month: "next month",
      next_quarter: "next quarter",
      next_year: "next year",
      prev_month: "the previous month",
      prev_quarter: "the previous quarter",
      prev_year: "the previous year",
      this_month: "this month",
      this_quarter: "this quarter",
      this_year: "this year",
      today: "today"
    },
    long_quarter: "quarter %{quarter}",
    short_quarter: "Q%{quarter}",
    range: "%{begin} - %{end}"
  }
)
