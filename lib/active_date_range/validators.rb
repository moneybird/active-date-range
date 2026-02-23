# frozen_string_literal: true

require "active_date_range/validators/resolve_value"
require "active_date_range/validators/date_range_validator"

# Register validator at top level so `validates :x, date_range: {}` works
::DateRangeValidator = ActiveDateRange::Validators::DateRangeValidator
