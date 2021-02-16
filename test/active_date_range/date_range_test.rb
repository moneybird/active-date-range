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

  def test_parse
    assert_equal ActiveDateRange::DateRange.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31)), ActiveDateRange::DateRange.parse(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
    assert_equal ActiveDateRange::DateRange.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31)), ActiveDateRange::DateRange.parse(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
    assert_equal ActiveDateRange::DateRange.new(Date.new(2013, 5, 1), Date.new(2013, 9, 1).at_end_of_month), ActiveDateRange::DateRange.parse("201305..201309")
    assert_equal ActiveDateRange::DateRange.new(Date.new(2013, 5, 1), Date.new(2013, 9, 1).at_end_of_month), ActiveDateRange::DateRange.parse("2013-05..2013-09")
    assert_equal ActiveDateRange::DateRange.new(Date.new(2014, 4, 15), Date.new(2014, 5, 23)), ActiveDateRange::DateRange.parse("20140415..20140523")
    assert_equal ActiveDateRange::DateRange.new(Date.new(2014, 4, 15), Date.new(2014, 5, 31)), ActiveDateRange::DateRange.parse("20140415..201405")
    assert_equal ActiveDateRange::DateRange.new(Date.new(2016, 5, 23), Date.new(2016, 5, 23)), ActiveDateRange::DateRange.parse("2016-05-23..2016-05-23")
    assert_equal ActiveDateRange::DateRange.new(Date.new(2014, 4, 1), Date.new(2014, 5, 15)), ActiveDateRange::DateRange.parse("201404..20140515")
    assert_equal ActiveDateRange::DateRange.new(Date.new(2014, 4, 1), Date.new(2014, 5, 15)), ActiveDateRange::DateRange.parse("2014-04..2014-05-15")
    assert_equal ActiveDateRange::DateRange.this_month, ActiveDateRange::DateRange.parse("this_month")
    assert_equal ActiveDateRange::DateRange.previous_month, ActiveDateRange::DateRange.parse("previous_month")
    assert_equal ActiveDateRange::DateRange.next_month, ActiveDateRange::DateRange.parse("next_month")
    assert_equal ActiveDateRange::DateRange.this_quarter, ActiveDateRange::DateRange.parse("this_quarter")
    assert_equal ActiveDateRange::DateRange.previous_quarter, ActiveDateRange::DateRange.parse("previous_quarter")
    assert_equal ActiveDateRange::DateRange.next_quarter, ActiveDateRange::DateRange.parse("next_quarter")
    assert_equal ActiveDateRange::DateRange.this_year, ActiveDateRange::DateRange.parse("this_year")
    assert_equal ActiveDateRange::DateRange.previous_year, ActiveDateRange::DateRange.parse("previous_year")
    assert_equal ActiveDateRange::DateRange.next_year, ActiveDateRange::DateRange.parse("next_year")
    (Date.new(2021, 1, 1)..Date.new(2021, 12, 31)).to_a.each do |date|
      assert_equal ActiveDateRange::DateRange.new(date, date), ActiveDateRange::DateRange.parse("#{date.strftime("%Y%m%d")}..#{date.strftime("%Y%m%d")}")
    end
    %w[2012..2013 2013011..2013051 foobar month 20-1301..20-1305 20160925..20160931].each do |format|
      assert_raises(ActiveDateRange::InvalidDateRangeFormat) { ActiveDateRange::DateRange.parse(format) }
    end
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

  def test_granularity
    assert_equal :month, ActiveDateRange::DateRange.this_month.granularity
    assert_equal :quarter, ActiveDateRange::DateRange.this_quarter.granularity
    assert_equal :year, ActiveDateRange::DateRange.this_year.granularity
  end

  def test_days
    assert_equal 1, ActiveDateRange::DateRange.parse("20210101..20210101").days
    assert_equal 31, ActiveDateRange::DateRange.parse("202101..202101").days
    assert_equal 365, ActiveDateRange::DateRange.parse("202101..202112").days
  end

  def test_to_param
    assert_equal "202001..202001", ActiveDateRange::DateRange.parse("202001..202001").to_param
    assert_equal "202001..202012", ActiveDateRange::DateRange.parse("202001..202012").to_param
    assert_equal "20200101..20201210", ActiveDateRange::DateRange.parse("20200101..20201210").to_param

    %w[
      this_month previous_month next_month this_quarter previous_quarter next_quarter
      this_year previous_year next_year
    ].each do |relative|
      assert_equal relative, ActiveDateRange::DateRange.parse(relative).to_param(relative: true)
    end
  end
end
