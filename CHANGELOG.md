* Add support for boundless ranges:

  ```
  date_range = DateRange.parse('202101..')
  date_range.boundless? # => true
  date_range.in_groups_of(:month) # => Enumerator::Lazy
  Model.where(date: date_range) # => SQL "WHERE date >= 2021-01-01"
  ```

  *Edwin Vlieg*

* Add ActiveModel type for date range:

  ```
  attribute :period, :date_range
  ```

  *Edwin Vlieg*

## 0.2.0

* Add support for weeks:

  - Shorthands for `this_week`, `next_week` and `prev_week`
  - `full_week?` and `one_week?`
  - `next` and `previous` now handle weeks correctly
  - Tests for biweekly calculations

  *Edwin Vlieg*

## 0.1.0

*   Initial import of the DateRange implementation from the internal implementation in the Moneybird code.

    *Edwin Vlieg*
