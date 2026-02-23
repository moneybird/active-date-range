# frozen_string_literal: true

require "test_helper"

class DateRangeValidatorTest < ActiveSupport::TestCase
  class BoundedModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { bounded: true }
  end

  class MinimumDurationModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { minimum_duration: 1.month }
  end

  class MaximumDurationModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { maximum_duration: 1.year }
  end

  class ExactDurationModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { exact_duration: 3.months }
  end

  class DurationRangeModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { duration: 1.month..1.year }
  end

  class FullPeriodsModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { full_periods_of: :month }
  end

  class StartsOnModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { starts_on: :beginning_of_month }
  end

  class EndsOnModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { ends_on: :end_of_month }
  end

  class CoversModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: { covers: -> { Date.new(2024, 6, 15) } }
  end

  class CombinedModel
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :period, :date_range

    validates :period, date_range: {
      bounded: true,
      minimum_duration: 1.month,
      maximum_duration: 1.year,
      full_periods_of: :month
    }
  end

  # not_a_date_range
  def test_not_a_date_range
    model = BoundedModel.new
    model.period = nil
    assert_not model.valid?
    assert_includes model.errors[:period], "is not a valid date range"
  end

  # bounded
  def test_bounded_valid
    model = BoundedModel.new
    model.period = ActiveDateRange::DateRange.this_month
    assert model.valid?
  end

  def test_bounded_invalid
    model = BoundedModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), nil)
    assert_not model.valid?
    assert_includes model.errors[:period], "must have both a start and end date"
  end

  # minimum_duration - calendar aware
  def test_minimum_duration_february_full_month
    model = MinimumDurationModel.new
    # Feb 2024 is 29 days (leap year), should pass 1.month minimum
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 2, 1), Date.new(2024, 2, 29))
    assert model.valid?, "February (leap year) should satisfy minimum_duration: 1.month"
  end

  def test_minimum_duration_february_non_leap
    model = MinimumDurationModel.new
    # Feb 2025 is 28 days (non-leap), should pass 1.month minimum
    model.period = ActiveDateRange::DateRange.new(Date.new(2025, 2, 1), Date.new(2025, 2, 28))
    assert model.valid?, "February (non-leap) should satisfy minimum_duration: 1.month"
  end

  def test_minimum_duration_too_short
    model = MinimumDurationModel.new
    # Jan 15..Feb 13 = 30 days but not a calendar month
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 15), Date.new(2024, 2, 13))
    assert_not model.valid?
    assert_includes model.errors[:period], "is too short (minimum duration is 1 month)"
  end

  def test_minimum_duration_passes_for_longer
    model = MinimumDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 3, 31))
    assert model.valid?
  end

  # maximum_duration - calendar aware
  def test_maximum_duration_valid
    model = MaximumDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 12, 31))
    assert model.valid?, "Full year should satisfy maximum_duration: 1.year"
  end

  def test_maximum_duration_leap_year
    model = MaximumDurationModel.new
    # 2024 is a leap year (366 days), should still pass 1.year max
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 12, 31))
    assert model.valid?, "Leap year (366 days) should satisfy maximum_duration: 1.year"
  end

  def test_maximum_duration_too_long
    model = MaximumDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2025, 1, 1))
    assert_not model.valid?
    assert_includes model.errors[:period], "is too long (maximum duration is 1 year)"
  end

  # exact_duration
  def test_exact_duration_valid
    model = ExactDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 3, 31))
    assert model.valid?
  end

  def test_exact_duration_too_short
    model = ExactDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 2, 28))
    assert_not model.valid?
    assert_includes model.errors[:period], "has the wrong duration (should be 3 months)"
  end

  def test_exact_duration_too_long
    model = ExactDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 6, 30))
    assert_not model.valid?
  end

  # duration range
  def test_duration_range_valid
    model = DurationRangeModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 6, 30))
    assert model.valid?
  end

  def test_duration_range_too_short
    model = DurationRangeModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 1, 15))
    assert_not model.valid?
    assert model.errors[:period].any? { |e| e.include?("too short") }
  end

  def test_duration_range_too_long
    model = DurationRangeModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2025, 6, 30))
    assert_not model.valid?
    assert model.errors[:period].any? { |e| e.include?("too long") }
  end

  # full_periods_of
  def test_full_periods_of_month_valid
    model = FullPeriodsModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 3, 31))
    assert model.valid?
  end

  def test_full_periods_of_month_invalid
    model = FullPeriodsModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 15), Date.new(2024, 3, 15))
    assert_not model.valid?
    assert_includes model.errors[:period], "must consist of full months"
  end

  # starts_on
  def test_starts_on_valid
    model = StartsOnModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 1, 15))
    assert model.valid?
  end

  def test_starts_on_invalid
    model = StartsOnModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 15), Date.new(2024, 2, 15))
    assert_not model.valid?
    assert_includes model.errors[:period], "must start at the beginning of month"
  end

  # ends_on
  def test_ends_on_valid
    model = EndsOnModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 15), Date.new(2024, 1, 31))
    assert model.valid?
  end

  def test_ends_on_invalid
    model = EndsOnModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 1, 15))
    assert_not model.valid?
    assert_includes model.errors[:period], "must end at the end of month"
  end

  # covers
  def test_covers_valid
    model = CoversModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 12, 31))
    assert model.valid?
  end

  def test_covers_invalid
    model = CoversModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 3, 31))
    assert_not model.valid?
    assert_includes model.errors[:period], "must include 2024-06-15"
  end

  # combined
  def test_combined_valid
    model = CombinedModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 6, 30))
    assert model.valid?
  end

  def test_combined_multiple_errors
    model = CombinedModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 15), Date.new(2024, 1, 20))
    assert_not model.valid?
    assert model.errors[:period].size > 1
  end

  # dynamic values with Proc
  def test_minimum_duration_with_proc
    klass = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :period, :date_range
      attribute :min_duration

      validates :period, date_range: { minimum_duration: ->(record) { record.min_duration } }
    end

    model = klass.new
    model.min_duration = 1.month
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 1, 31))
    assert model.valid?

    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), Date.new(2024, 1, 15))
    assert_not model.valid?
  end

  # boundless ranges skip duration checks
  def test_minimum_duration_skips_boundless
    model = MinimumDurationModel.new
    model.period = ActiveDateRange::DateRange.new(Date.new(2024, 1, 1), nil)
    assert model.valid?
  end
end
