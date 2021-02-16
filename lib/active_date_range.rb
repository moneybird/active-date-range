# frozen_string_literal: true

require "active_date_range/version"
require "active_date_range/date_range"

module ActiveDateRange
  class Error < StandardError; end

  class InvalidDateRange < StandardError; end
  # Your code goes here...

  def initialize(start_date, end_date)
    DateRange.new(start_date, end_date)
  end
end
