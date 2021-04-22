# frozen_string_literal: true

require "test_helper"

class ActiveDateRangeHumanizerTest < ActiveSupport::TestCase
  def range
    ActiveDateRange::DateRange
  end

  def test_humanize_relative
    assert_equal "this year", ActiveDateRange::Humanizer.new(range.this_year, format: :relative).humanize
    assert_equal "this month", ActiveDateRange::Humanizer.new(range.this_month, format: :relative).humanize
    assert_equal "this quarter", ActiveDateRange::Humanizer.new(range.this_quarter, format: :relative).humanize
    assert_equal "the previous year", ActiveDateRange::Humanizer.new(range.prev_year, format: :relative).humanize
    assert_equal "the previous month", ActiveDateRange::Humanizer.new(range.prev_month, format: :relative).humanize
    assert_equal "the previous quarter", ActiveDateRange::Humanizer.new(range.prev_quarter, format: :relative).humanize

    assert_equal "2019", ActiveDateRange::Humanizer.new(range.parse("201901..201912"), format: :relative).humanize
    assert_equal "Jan 2020", ActiveDateRange::Humanizer.new(range.parse("202001..202001"), format: :relative).humanize
  end

  def test_humanize_one_day
    assert_equal "Jan 12, 2013", ActiveDateRange::Humanizer.new(range.parse("20130112..20130112")).humanize
    assert_equal "January 12, 2013", ActiveDateRange::Humanizer.new(range.parse("20130112..20130112"), format: :long).humanize
  end

  def test_humanize_month
    assert_equal "Jan 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201301")).humanize
    assert_equal "January 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201301"), format: :long).humanize
    assert_equal "Jan - Feb 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201302")).humanize
  end

  def test_humanize_quarter
    assert_equal "Q1 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201303")).humanize
    assert_equal "quarter 1 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201303"), format: :long).humanize
    assert_equal "Q1 - Q2 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201306")).humanize
    assert_equal "Q1 2013 - Q2 2014", ActiveDateRange::Humanizer.new(range.parse("201301..201406")).humanize
    assert_equal "quarter 1 - quarter 2 2013", ActiveDateRange::Humanizer.new(range.parse("201301..201306"), format: :long).humanize
  end

  def test_humanize_year
    assert_equal "2013", ActiveDateRange::Humanizer.new(range.parse("201301..201312")).humanize
    assert_equal "2008 - 2010", ActiveDateRange::Humanizer.new(range.parse("200801..201012")).humanize
  end

  def test_humanize_month_years
    assert_equal "Jan 2013 - May 2014", ActiveDateRange::Humanizer.new(range.parse("201301..201405")).humanize
    assert_equal "January 2013 - May 2014", ActiveDateRange::Humanizer.new(range.parse("201301..201405"), format: :long).humanize
    assert_equal "January 12, 2013 - May 15, 2014", ActiveDateRange::Humanizer.new(range.parse("20130112..20140515"), format: :long).humanize
    assert_equal "Jun 02 - Jun 28, 2014", ActiveDateRange::Humanizer.new(range.parse("20140602..20140628")).humanize
  end

  def test_humanize_explicit
    assert_equal "July 2015 - June 2016", ActiveDateRange::Humanizer.new(range.parse("20150701..20160630"), format: :explicit).humanize
    assert_equal "January - June 2015", ActiveDateRange::Humanizer.new(range.parse("20150101..20150630"), format: :explicit).humanize
    assert_equal "January - December 2015", ActiveDateRange::Humanizer.new(range.parse("20150101..20151231"), format: :explicit).humanize
  end
end
