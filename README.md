# Active Date Range

`ActiveDateRange` provides a range of dates with a powerful API to manipulate and use date ranges in your software. Date ranges are commonly used in reporting tools, but can be of use in many situation where you need filtering.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_date_range'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_date_range

## Usage

### Initialize a new date range

Initialize a new range:

```ruby
ActiveDateRange::DateRange.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31))
ActiveDateRange::DateRange.new(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
```

You can also use shorthands to initialize a range relative to today. Shorthands are available for `this`, `prev` and `next` for the ranges `month`, `quarter` and `year`:

```ruby
ActiveDateRange::DateRange.this_month
ActiveDateRange::DateRange.this_year
ActiveDateRange::DateRange.this_quarter
ActiveDateRange::DateRange.prev_month
ActiveDateRange::DateRange.prev_year
ActiveDateRange::DateRange.prev_quarter
ActiveDateRange::DateRange.next_month
ActiveDateRange::DateRange.next_year
ActiveDateRange::DateRange.next_quarter
```

The third option is to use parse:

```ruby
ActiveDateRange::DateRange.parse('202101..202112')
ActiveDateRange::DateRange.parse('20210101..20210115')
```

Parse accepts three formats: `YYYYMM..YYYYMM`, `YYYYMMDD..YYYYMMDD` and any short hand like `this_month`.

### The date range instance

A `DateRange` object is an extension of a regular `Range` object. You can use [all methods available on `Range`](https://ruby-doc.org/core-3.0.0/Range.html):

```ruby
date_range = ActiveDateRange::DateRange.parse('202101..202112')
date_range.begin                            # => Date.new(2021, 1, 1)
date_range.end                              # => Date.new(2021, 12, 31)
date_range.cover?(Date.new(2021, 2, 1))     # => true
```

`DateRange` adds extra methods to work with date ranges:

```ruby
date_range.days                             # => 365
date_range.months                           # => 12
date_range.quarters                         # => 4
date_range.years                            # => 1
date_range.one_month?                       # => false
date_range.one_year?                        # => true
date_range.full_year?                       # => true
date_range.same_year?                       # => true
date_range.before?(Date.new(2022, 1, 1))    # => true
date_range.after?(ActiveDateRange::DateRange.parse('202001..202012')) # => true
date_range.granularity                      # => :year
date_range.to_param                         # => "202101..202112"
date_range.to_param(relative: true)         # => "this_year"
```

You can also do calculations with the ranges:

```ruby
date_range.previous                             # => DateRange.parse('202001..202012')
date_range.previous(2)                          # => DateRange.parse('201901..202012')
date_range.next                                 # => DateRange.parse('202201..202212')
date_range + DateRange.parse('202201..202202')  # => DateRange.parse('202101..202202')
date_range.in_groups_of(:month)                 # => [DateRange.parse('202101..202101'), ..., DateRange.parse('202112..202112')]
```

And lastly you can call `.humanize` to get a localizable human representation of the range for in the user interface:

```ruby
date_range.humanize                      # => '2021'
date_range.humanize(format: :explicit)   # => 'January 1st, 2021 - December 31st 2021'
```

### Usage example

Use the shorthands to link to a specific period:

```ruby
<%= link_to "Show report for #{DateRange.this_year.humanize}", report_url(period: DateRange.this_year.to_param(relative: true)) %>
```

Because we use `to_params(relative: true)`, the user gets a bookmarkable URL which always points to the current year. If you need the URL to be bookmarkable and always point to the same period, remove `relative: true`.

In your controller, use the parameter in your queries:

```ruby
def report
  @period = DateRange.parse(params[:period])
  @data = SomeModel.where(date: @period)
end
```

In the report view, use the period object to render previous and next links:

```ruby
<%= link_to "Next period", report_url(period: @period.next) %>
<%= link_to "Previous period", report_url(period: @period.previous) %>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/moneybird/active-date-range.

