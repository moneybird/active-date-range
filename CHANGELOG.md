## 0.5.0

* Add `size` and `length` methods that return an `ActiveSupport::Duration`, compatible with `validates_length_of`:

```ruby
validates_length_of :period, maximum: 10.years
```

  *Edwin Vlieg*

* Add `cap_end` and `cap_begin` to limit a range to a given duration:

```ruby
DateRange.parse("202101..202512").cap_end(2.years)
# => DateRange(2021-01-01..2022-12-31)

DateRange.parse("202101..202512").cap_begin(2.years)
# => DateRange(2024-01-01..2025-12-31)
```

  *Edwin Vlieg*

## 0.4.2

* Add shorthand class methods for creating DateRanges:

```ruby
DateRange.year(2026)       # => DateRange(2026-01-01..2026-12-31)
DateRange.quarter(2026, 4) # => DateRange(2026-10-01..2026-12-31)
DateRange.month(2026, 1)   # => DateRange(2026-01-01..2026-01-31)
DateRange.week(2026, 1)    # => DateRange for ISO week 1 of 2026
```

  *Edwin Vlieg*

## 0.4.1

* Fix dependency issues in gemspec

  *Vincent Oord*

## 0.4.0

* Add #stretch_to_end_of_month:

```
DateRange.parse("20250101..20250112).stretch_to_end_of_month
# => "20250101..20250131"
```

  *Vincent Oord*

* Add exceeds? to check if the period does not exceed a given limit.

```
DateRange.parse("202501..202503).exceeds?(1.month)
# => true

DateRange.parse("20250101..20250105).exceeds?(1.week)
# => false
```

  *Vincent Oord*

* Update to Ruby 3.4.6 compatibility

  *Vincent Oord*

## 0.3.3

* Add current? to check if the period containts the current date.

  *Edwin Vlieg*

* Add .from_date_and_duration:

  ```
  DateRange.from_date_and_duration(Date.new(2023, 1, 1), :month) # => Range
  ```

  *Edwin Vlieg*

## 0.3.2

* Add this_month?, this_quarter? and this_year? to check if a period is the current month, quarter or year

  *Edwin Vlieg*


## 0.3.1

* Fix issue with `next` not returning a full year when leap years are in the range

  *Edwin Vlieg*

## 0.3.0

* `include?` now behaves like `cover?` for better performance

  *Edwin Vlieg*

* Add intersection support:

  ```
  date_range.intersection(other_date_range) # => DateRange
  ```

  *Edwin Vlieg*


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
