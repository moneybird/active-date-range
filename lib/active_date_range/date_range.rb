# frozen_string_literal: true

module ActiveDateRange
  class DateRange < Range
    SHORTHANDS = {
      this_month: -> { DateRange.new(Time.zone.today.all_month) },
      previous_month: -> { DateRange.new(1.month.ago.to_date.all_month) },
      next_month: -> { DateRange.new(1.month.from_now.to_date.all_month) },
      this_quarter: -> { DateRange.new(Time.zone.today.all_quarter) },
      previous_quarter: -> { DateRange.new(3.months.ago.to_date.all_quarter) },
      next_quarter: -> { DateRange.new(3.months.from_now.to_date.all_quarter) },
      this_year: -> { DateRange.new(Time.zone.today.all_year) },
      previous_year: -> { DateRange.new(12.months.ago.to_date.all_year) },
      next_year: -> { DateRange.new(12.months.from_now.to_date.all_year) }
    }.freeze

    class << self
      SHORTHANDS.each do |method, range|
        define_method(method, range)
      end
    end

    def initialize(begin_date, end_date = nil)
      begin_date, end_date = begin_date.begin, begin_date.end if begin_date.kind_of?(Range)
      begin_date = begin_date.to_date if begin_date.kind_of?(Time)
      end_date = end_date.to_date if end_date.kind_of?(Time)

      raise InvalidDateRange, "Date range invalid, begin should be a date" unless begin_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, end should be a date" unless end_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, begin #{begin_date} is after end #{end_date}" if begin_date >= end_date

      super(begin_date, end_date)
    end
  end
end
