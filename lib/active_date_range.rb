# frozen_string_literal: true

# require "active_support"
require "active_support/core_ext/array"
require "active_support/core_ext/time"
require "active_support/core_ext/date"
require "active_support/core_ext/integer"
require "active_date_range/core_ext/integer"
require "active_date_range/core_ext/date"

require "active_date_range/version"
require "active_date_range/date_range"
require "active_date_range/humanizer"
require "active_date_range/active_model_type"

module ActiveDateRange
  class Error < StandardError; end
  class InvalidDateRange < Error; end
  class InvalidAddition < Error; end
  class InvalidDateRangeFormat < Error; end
  class UnknownGranularity < Error; end
  class BoundlessRangeError < Error; end
end
