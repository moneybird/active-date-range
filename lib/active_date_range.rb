# frozen_string_literal: true

# require "active_support"
require "active_support/core_ext/time"
require "active_support/core_ext/date"
require "active_support/core_ext/integer"

require "active_date_range/version"
require "active_date_range/date_range"

module ActiveDateRange
  class Error < StandardError; end
  class InvalidDateRange < StandardError; end
  class InvalidAddition < StandardError; end


  def initialize(start_date, end_date)
    DateRange.new(start_date, end_date)
  end
end
