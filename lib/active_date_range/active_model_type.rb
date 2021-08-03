# frozen_string_literal: true

module ActiveDateRange
  class DateRangeType < ActiveModel::Type::String
    def cast(value)
      ActiveDateRange::DateRange.parse(value)
    end
  end
end

if defined?(ActiveModel)
  ActiveModel::Type.register(:date_range, ActiveDateRange::DateRangeType)
end
