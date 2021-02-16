# frozen_string_literal: true

require "test_helper"

class ActiveDateRangeDateRangeTest < ActiveSupport::TestCase
  def test_initialize
    range = ActiveDateRange::DateRange.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31))
    assert_kind_of ActiveDateRange::DateRange, range
    assert_kind_of Range, range
    assert_kind_of Date, range.begin
    assert_kind_of Date, range.end
  end

  def test_initialize_no_dates
    assert_raises(ActiveDateRange::InvalidDateRange) { ActiveDateRange::DateRange.new(1, 2) }
    assert_raises(ActiveDateRange::InvalidDateRange) { ActiveDateRange::DateRange.new(Date.new(2021, 1, 1), 2) }
    assert_raises(ActiveDateRange::InvalidDateRange) { ActiveDateRange::DateRange.new(1, Date.new(2021, 12, 31)) }
  end

  def test_initialize_end_before_start
    assert_raises(ActiveDateRange::InvalidDateRange) { ActiveDateRange::DateRange.new(Date.new(2021, 12, 31), Date.new(2021, 1, 1)) }
    assert_raises(ActiveDateRange::InvalidDateRange) { ActiveDateRange::DateRange.new(Date.new(2021, 1, 1), Date.new(2021, 1, 1)) }
  end
end
