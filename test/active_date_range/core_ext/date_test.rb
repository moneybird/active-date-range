# frozen_string_literal: true

require "test_helper"

class ActiveDateRangeCoreExtDateTest < ActiveSupport::TestCase
  def test_quarter
    assert_equal 1, Date.new(2020, 1, 1).quarter
    assert_equal 2, Date.new(2020, 4, 1).quarter
    assert_equal 3, Date.new(2020, 7, 1).quarter
    assert_equal 4, Date.new(2020, 10, 1).quarter
  end

  def test_next_quarter
    assert_equal Date.new(2020, 4, 1), Date.new(2020, 1, 1).next_quarter
    assert_equal Date.new(2020, 7, 1), Date.new(2020, 4, 1).next_quarter
    assert_equal Date.new(2020, 10, 1), Date.new(2020, 7, 1).next_quarter
    assert_equal Date.new(2021, 1, 1), Date.new(2020, 10, 1).next_quarter
  end

  def test_prev_quarter
    assert_equal Date.new(2019, 10, 1), Date.new(2020, 1, 1).prev_quarter
    assert_equal Date.new(2020, 1, 1), Date.new(2020, 4, 1).prev_quarter
    assert_equal Date.new(2020, 4, 1), Date.new(2020, 7, 1).prev_quarter
    assert_equal Date.new(2020, 7, 1), Date.new(2020, 10, 1).prev_quarter
  end
end
