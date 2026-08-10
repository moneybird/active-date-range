# frozen_string_literal: true

require "active_model"
require "test_helper"

class ActiveDateRangeAttributesTest < ActiveSupport::TestCase
  class TestReport
    include ActiveModel::Attributes

    attribute :period, :date_range
  end

  def test_date_range_conversion
    report = TestReport.new
    report.period = "this_month"
    assert_equal ActiveDateRange::DateRange.this_month, report.period
  end

  def test_date_range_conversion_error
    report = TestReport.new
    report.period = "unknown"
    assert_raises(ActiveDateRange::InvalidDateRangeFormat) { report.period }
  end

  class SafeParseTestReport
    include ActiveModel::Attributes

    attribute :period, :date_range, safe_parse: true
  end

  def test_safe_parse_date_range_conversion
    report = SafeParseTestReport.new
    report.period = "this_month"
    assert_equal ActiveDateRange::DateRange.this_month, report.period
  end

  def test_safe_parse_date_range_conversion_returns_nil
    report = SafeParseTestReport.new
    report.period = "unknown"
    assert_nil report.period
  end

  def test_safe_parse_date_range_conversion_returns_nil_for_reversed_range
    report = SafeParseTestReport.new
    report.period = "202503..202501"
    assert_nil report.period
  end
end
