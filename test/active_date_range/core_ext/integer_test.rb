# frozen_string_literal: true

require "test_helper"

class ActiveDateRangeCoreExtIntegerTest < ActiveSupport::TestCase
  def test_quarter
    assert_equal 3.months, 1.quarter
    assert_equal 6.months, 2.quarters
    assert_equal 1.year, 4.quarters
  end
end
