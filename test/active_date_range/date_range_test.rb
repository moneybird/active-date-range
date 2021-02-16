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

  def test_initialize_range
    assert_kind_of Range, ActiveDateRange::DateRange.new(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
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

  def test_shorthands
    assert_equal Date.today.all_month, ActiveDateRange::DateRange.this_month
    assert_equal 1.month.ago.to_date.all_month, ActiveDateRange::DateRange.previous_month
    assert_equal 1.month.from_now.to_date.all_month, ActiveDateRange::DateRange.next_month
    assert_equal Date.today.all_quarter, ActiveDateRange::DateRange.this_quarter
    assert_equal 3.months.ago.to_date.all_quarter, ActiveDateRange::DateRange.previous_quarter
    assert_equal 3.months.from_now.to_date.all_quarter, ActiveDateRange::DateRange.next_quarter
    assert_equal Date.today.all_year, ActiveDateRange::DateRange.this_year
    assert_equal 12.months.ago.to_date.all_year, ActiveDateRange::DateRange.previous_year
    assert_equal 12.months.from_now.to_date.all_year, ActiveDateRange::DateRange.next_year
  end
end
