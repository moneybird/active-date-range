# frozen_string_literal: true

module ActiveDateRange
  class DateRangeType < ActiveModel::Type::String
    # Pass <tt>safe_parse: true</tt> for attributes fed by input you don't control, like a query
    # parameter. The attribute then casts through .safe_parse, so it returns nil instead of
    # raising:
    #
    #   attribute :period, :date_range, safe_parse: true
    def initialize(safe_parse: false)
      @safe_parse = safe_parse
      super()
    end

    def cast(value)
      return ActiveDateRange::DateRange.safe_parse(value) if @safe_parse

      ActiveDateRange::DateRange.parse(value)
    end
  end
end

if defined?(ActiveModel)
  ActiveModel::Type.register(:date_range, ActiveDateRange::DateRangeType)
end
