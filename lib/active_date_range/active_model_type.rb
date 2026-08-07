# frozen_string_literal: true

module ActiveDateRange
  class DateRangeType < ActiveModel::Type::String
    # Pass <tt>safe: true</tt> for attributes fed by input you don't control, like a query
    # parameter. The attribute then casts to nil instead of raising:
    #
    #   attribute :period, :date_range, safe: true
    def initialize(safe: false)
      @safe = safe
      super()
    end

    def cast(value)
      @safe ? ActiveDateRange::DateRange.safe_parse(value) : ActiveDateRange::DateRange.parse(value)
    end
  end
end

if defined?(ActiveModel)
  ActiveModel::Type.register(:date_range, ActiveDateRange::DateRangeType)
end
