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

  def test_addition
    a = ActiveDateRange::DateRange.new(Date.new(2021, 1, 1)..Date.new(2021, 1, 31))
    b = ActiveDateRange::DateRange.new(Date.new(2021, 2, 1)..Date.new(2021, 2, 28))
    c = ActiveDateRange::DateRange.new(Date.new(2021, 3, 1)..Date.new(2021, 3, 31))
    assert_equal Date.new(2021, 1, 1)..Date.new(2021, 2, 28), a + b

    assert_raises(ActiveDateRange::InvalidAddition) { a + c }
  end

  def test_one_methods
    assert ActiveDateRange::DateRange.this_month.one_month?
    assert ActiveDateRange::DateRange.this_quarter.one_quarter?
    assert ActiveDateRange::DateRange.this_year.one_year?

    assert_not ActiveDateRange::DateRange.this_month.one_quarter?
    assert_not ActiveDateRange::DateRange.this_month.one_year?

    assert_not ActiveDateRange::DateRange.this_quarter.one_month?
    assert_not ActiveDateRange::DateRange.this_quarter.one_year?

    assert_not ActiveDateRange::DateRange.this_year.one_month?
    assert_not ActiveDateRange::DateRange.this_year.one_quarter?

    assert_not (ActiveDateRange::DateRange.this_month + ActiveDateRange::DateRange.next_month).one_month?
    assert_not (ActiveDateRange::DateRange.this_quarter + ActiveDateRange::DateRange.next_quarter).one_quarter?
    assert_not (ActiveDateRange::DateRange.this_year + ActiveDateRange::DateRange.next_year).one_year?
  end

  def test_full_methods
    assert ActiveDateRange::DateRange.this_month.full_month?
    assert ActiveDateRange::DateRange.this_quarter.full_month?
    assert ActiveDateRange::DateRange.this_quarter.full_quarter?
    assert ActiveDateRange::DateRange.this_year.full_month?
    assert ActiveDateRange::DateRange.this_year.full_quarter?
    assert ActiveDateRange::DateRange.this_year.full_year?

    assert ActiveDateRange::DateRange.new(Date.new(2020, 1, 1), Date.new(2020, 9, 30)).full_month?
    assert ActiveDateRange::DateRange.new(Date.new(2020, 1, 1), Date.new(2020, 9, 30)).full_quarter?
    assert ActiveDateRange::DateRange.new(Date.new(2020, 1, 1), Date.new(2021, 12, 31)).full_year?

    assert_not ActiveDateRange::DateRange.new(Date.new(2020, 1, 1), Date.new(2020, 9, 29)).full_month?
    assert_not ActiveDateRange::DateRange.new(Date.new(2020, 1, 1), Date.new(2020, 9, 29)).full_quarter?
    assert_not ActiveDateRange::DateRange.new(Date.new(2020, 1, 1), Date.new(2020, 12, 30)).full_year?
  end
end
