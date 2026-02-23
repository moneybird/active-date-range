# frozen_string_literal: true

module ActiveDateRange
  module Validators
    module ResolveValue
      private
        def resolve_value(record, value)
          case value
          when Proc   then value.arity == 0 ? value.call : value.call(record)
          when Symbol then record.send(value)
          else value
          end
        end
    end
  end
end
