# frozen_string_literal: true

module ActiveDateRange
  class DateRange < Range
    def initialize(begin_date, end_date)
      raise InvalidDateRange, "Date range invalid, begin should be a date" unless begin_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, end should be a date" unless end_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, begin #{begin_date} is after end #{end_date}" if begin_date >= end_date

      begin_date = begin_date.to_date if begin_date.kind_of?(Time)
      end_date = end_date.to_date if end_date.kind_of?(Time)

      super(begin_date, end_date)
    end
  end
end
