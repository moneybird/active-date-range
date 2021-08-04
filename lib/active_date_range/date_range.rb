# frozen_string_literal: true

module ActiveDateRange
  # Provides a <tt>DateRange</tt> with parsing, calculations and query methods
  class DateRange < Range
    SHORTHANDS = {
      this_month: -> { DateRange.new(Time.zone.today.all_month) },
      prev_month: -> { DateRange.new(1.month.ago.to_date.all_month) },
      next_month: -> { DateRange.new(1.month.from_now.to_date.all_month) },
      this_quarter: -> { DateRange.new(Time.zone.today.all_quarter) },
      prev_quarter: -> { DateRange.new(3.months.ago.to_date.all_quarter) },
      next_quarter: -> { DateRange.new(3.months.from_now.to_date.all_quarter) },
      this_year: -> { DateRange.new(Time.zone.today.all_year) },
      prev_year: -> { DateRange.new(12.months.ago.to_date.all_year) },
      next_year: -> { DateRange.new(12.months.from_now.to_date.all_year) },
      this_week: -> { DateRange.new(Time.zone.today.all_week) },
      prev_week: -> { DateRange.new(1.week.ago.to_date.all_week) },
      next_week: -> { DateRange.new(1.week.from_now.to_date.all_week) }
    }.freeze

    RANGE_PART_REGEXP = %r{\A(?<year>((1\d|2\d)\d\d))-?(?<month>0[1-9]|1[012])-?(?<day>[0-2]\d|3[01])?\z}

    class << self
      SHORTHANDS.each do |method, range|
        define_method(method, range)
      end
    end

    # Parses a date range string to a <tt>DateRange</tt> instance. Valid formats are:
    # - A relative shorthand: <tt>this_month</tt>, <tt>prev_month</tt>, <tt>next_month</tt>, etc.
    # - A begin and end date: <tt>YYYYMMDD..YYYYMMDD</tt>
    # - A begin and end month: <tt>YYYYMM..YYYYMM</tt>
    def self.parse(input)
      return DateRange.new(input) if input.kind_of?(Range)
      return SHORTHANDS[input.to_sym].call if SHORTHANDS.key?(input.to_sym)

      begin_date, end_date = input.split("..")
      raise InvalidDateRangeFormat, "#{input} doesn't have a begin..end format" if begin_date.blank? && end_date.blank?

      DateRange.new(parse_date(begin_date), parse_date(end_date, last: true))
    end

    def self.parse_date(input, last: false)
      return if input.blank?

      match_data = input.match(RANGE_PART_REGEXP)
      raise InvalidDateRangeFormat, "#{input} isn't a valid date format YYYYMMDD or YYYYMM" unless match_data

      date = Date.new(
        match_data[:year].to_i,
        match_data[:month].to_i,
        match_data[:day]&.to_i || 1
      )
      return date.at_end_of_month if match_data[:day].nil? && last

      date
    rescue Date::Error
      raise InvalidDateRangeFormat
    end

    private_class_method :parse_date

    # Initializes a new DateRange. Accepts both a begin and end date or a range of dates.
    # Make sures the begin date is before the end date.
    def initialize(begin_date, end_date = nil)
      begin_date, end_date = begin_date.begin, begin_date.end if begin_date.kind_of?(Range)
      begin_date, end_date = begin_date.first, begin_date.last if begin_date.kind_of?(Array)
      begin_date = begin_date.to_date if begin_date.kind_of?(Time)
      end_date = end_date.to_date if end_date.kind_of?(Time)

      raise InvalidDateRange, "Date range invalid, begin should be a date" if begin_date && !begin_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, end should be a date" if end_date && !end_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, begin #{begin_date} is after end #{end_date}" if begin_date && end_date && begin_date > end_date

      super(begin_date, end_date)
    end

    # Adds two date ranges together. Fails when the ranges are not subsequent.
    def +(other)
      raise InvalidAddition if self.end != (other.begin - 1.day)

      DateRange.new(self.begin, other.end)
    end

    # Sorts two date ranges by the begin date.
    def <=>(other)
      self.begin <=> other.begin
    end

    def boundless?
      self.begin.nil? || self.end.nil?
    end

    # Returns the number of days in the range
    def days
      return if boundless?

      @days ||= (self.end - self.begin).to_i + 1
    end

    # Returns the number of months in the range or nil when range is no full month
    def months
      return nil unless full_month?

      ((self.end.year - self.begin.year) * 12) + (self.end.month - self.begin.month + 1)
    end

    # Returns the number of quarters in the range or nil when range is no full quarter
    def quarters
      return nil unless full_quarter?

      months / 3
    end

    # Returns the number of years on the range or nil when range is no full year
    def years
      return nil unless full_year?

      months / 12
    end

    # Returns the number of weeks on the range or nil when range is no full week
    def weeks
      return nil unless full_week?

      days / 7
    end

    # Returns true when begin of the range is at the beginning of the month
    def begin_at_beginning_of_month?
      self.begin.present? && self.begin.day == 1
    end

    # Returns true when begin of the range is at the beginning of the quarter
    def begin_at_beginning_of_quarter?
      self.begin.present? && begin_at_beginning_of_month? && [1, 4, 7, 10].include?(self.begin.month)
    end

    # Returns true when begin of the range is at the beginning of the year
    def begin_at_beginning_of_year?
      self.begin.present? && begin_at_beginning_of_month? && self.begin.month == 1
    end

    # Returns true when begin of the range is at the beginning of the week
    def begin_at_beginning_of_week?
      self.begin.present? && self.begin == self.begin.at_beginning_of_week
    end

    # Returns true when the range is exactly one month long
    def one_month?
      (28..31).cover?(days) &&
        begin_at_beginning_of_month? &&
        self.end == self.begin.at_end_of_month
    end

    # Returns true when the range is exactly one quarter long
    def one_quarter?
      (90..92).cover?(days) &&
        begin_at_beginning_of_quarter? &&
        self.end == self.begin.at_end_of_quarter
    end

    # Returns true when the range is exactly one year long
    def one_year?
      (365..366).cover?(days) &&
        begin_at_beginning_of_year? &&
        self.end == self.begin.at_end_of_year
    end

    def one_week?
      days == 7 &&
        begin_at_beginning_of_week? &&
        self.end == self.begin.at_end_of_week
    end

    # Returns true when the range is exactly one or more months long
    def full_month?
      begin_at_beginning_of_month? && self.end.present? && self.end == self.end.at_end_of_month
    end

    alias :full_months? :full_month?

    # Returns true when the range is exactly one or more quarters long
    def full_quarter?
      begin_at_beginning_of_quarter? && self.end.present? && self.end == self.end.at_end_of_quarter
    end

    alias :full_quarters? :full_quarter?

    # Returns true when the range is exactly one or more years long
    def full_year?
      begin_at_beginning_of_year? && self.end.present? && self.end == self.end.at_end_of_year
    end

    alias :full_years? :full_year?

    # Returns true when the range is exactly one or more weeks long
    def full_week?
      begin_at_beginning_of_week? && self.end.present? && self.end == self.end.at_end_of_week
    end

    alias :full_weeks? :full_week?

    # Returns true when begin and end are in the same year
    def same_year?
      !boundless? && self.begin.year == self.end.year
    end

    # Returns true when the date range is before the given date. Accepts both a <tt>Date</tt>
    # and <tt>DateRange</tt> as input.
    def before?(date)
      date = date.begin if date.kind_of?(DateRange)
      self.end.present? && self.end.before?(date)
    end

    # Returns true when the date range is after the given date. Accepts both a <tt>Date</tt>
    # and <tt>DateRange</tt> as input.
    def after?(date)
      date = date.end if date.kind_of?(DateRange)
      self.begin.present? && self.begin.after?(date)
    end

    # Returns the granularity of the range. Returns either <tt>:year</tt>, <tt>:quarter</tt> or
    # <tt>:month</tt> based on if the range has exactly this length.
    #
    #   DateRange.this_month.granularity    # => :month
    #   DateRange.this_quarter.granularity  # => :quarter
    #   DateRange.this_year.granularity     # => :year
    def granularity
      if one_year?
        :year
      elsif one_quarter?
        :quarter
      elsif one_month?
        :month
      elsif one_week?
        :week
      end
    end

    # Returns a string representation of the date range relative to today. For example
    # a range of 2021-01-01..2021-12-31 will return `this_year` when the current date
    # is somewhere in 2021.
    def relative_param
      @relative_param ||= SHORTHANDS
        .select { |key, _| key.end_with?(granularity.to_s) }
        .find { |key, range| self == range.call }
        &.first
        &.to_s
    end

    # Returns a param representation of the date range. When `relative` is true,
    # the `relative_param` is returned when available. This allows for easy bookmarking of
    # URL's that always return the current month/quarter/year for the end user.
    #
    # When `relative` is false, a `YYYYMMDD..YYYYMMDD` or `YYYYMM..YYYYMM` format is
    # returned. The output of `to_param` is compatible with the `parse` method.
    #
    #   DateRange.parse("202001..202001").to_param                  # => "202001..202001"
    #   DateRange.parse("20200101..20200115").to_param              # => "20200101..20200115"
    #   DateRange.parse("202001..202001").to_param(relative: true)  # => "this_month"
    def to_param(relative: true)
      if relative && relative_param
        relative_param
      else
        format = full_month? ? "%Y%m" : "%Y%m%d"
        "#{self.begin&.strftime(format)}..#{self.end&.strftime(format)}"
      end
    end

    # Returns a Range with begin and end as DateTime instances.
    def to_datetime_range
      Range.new(self.begin.to_datetime.at_beginning_of_day, self.end.to_datetime.at_end_of_day)
    end

    def to_s
      "#{self.begin.strftime('%Y%m%d')}..#{self.end.strftime('%Y%m%d')}"
    end

    # Returns the period previous to the current period. `periods` can be raised to return more
    # than 1 previous period.
    #
    #   DateRange.this_month.previous # => DateRange.prev_month
    #   DateRange.this_month.previous(2) # => DateRange.prev_month.previous + DateRange.prev_month
    def previous(periods = 1)
      raise BoundlessRangeError, "Can't calculate previous for boundless range" if boundless?

      begin_date = if granularity
        self.begin - periods.send(granularity)
      elsif full_month?
        in_groups_of(:month).first.previous(periods * months).begin
      else
        (self.begin - (periods * days).days)
      end

      begin_date = begin_date.at_beginning_of_month if full_month?

      DateRange.new(begin_date, self.begin - 1.day)
    end

    # Returns the period next to the current period. `periods` can be raised to return more
    # than 1 next period.
    #
    #   DateRange.this_month.next # => DateRange.next_month
    #   DateRange.this_month.next(2) # => DateRange.next_month + DateRange.next_month.next
    def next(periods = 1)
      raise BoundlessRangeError, "Can't calculate next for boundless range" if boundless?

      end_date = self.end + (granularity ? periods.send(granularity) : days.days)
      end_date = end_date.at_end_of_month if full_month?

      DateRange.new(self.end + 1.day, end_date)
    end

    # Returns an array with date ranges containing full months/quarters/years in the current range.
    # Comes in handy when you need to have columns by month for a given range:
    # `DateRange.this_year.in_groups_of(:months)`
    #
    # Always returns full months/quarters/years, from the first to the last day of the period.
    # The first and last item in the array can have a partial month/quarter/year, depending on
    # the date range.
    #
    #   DateRange.parse("202101..202103").in_groups_of(:month) # => [DateRange.parse("202001..202001"), DateRange.parse("202002..202002"), DateRange.parse("202003..202003")]
    #   DateRange.parse("202101..202106").in_groups_of(:month, amount: 2) # => [DateRange.parse("202001..202002"), DateRange.parse("202003..202004"), DateRange.parse("202005..202006")]
    def in_groups_of(granularity, amount: 1)
      raise BoundlessRangeError, "Can't group date range without a begin." if self.begin.nil?

      if boundless?
        grouped_collection(granularity, amount: amount)
      else
        grouped_collection(granularity, amount: amount).to_a
      end
    end

    # Returns a human readable format for the date range. See DateRange::Humanizer for options.
    def humanize(format: :short)
      Humanizer.new(self, format: format).humanize
    end

    # Returns the intersection of the current and the other date range
    def intersection(other)
      intersection = self.to_a.intersection(other.to_a).sort
      DateRange.new(intersection) if intersection.any?
    end

    private
      def grouped_collection(granularity, amount: 1)
        raise UnknownGranularity, "Unknown granularity #{granularity}. Valid are: month, quarter and year" unless %w[month quarter year].include?(granularity.to_s)

        lazy
          .chunk { |d| [d.year, d.send(granularity)] }
          .map { |_, group| DateRange.new(group.first..group.last) }
          .with_index
          .slice_before { |_, index| index % amount == 0 }
          .map { |group| group.map(&:first).inject(:+) }
      end
  end
end
