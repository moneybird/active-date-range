# frozen_string_literal: true

module ActiveDateRange
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
      next_year: -> { DateRange.new(12.months.from_now.to_date.all_year) }
    }.freeze

    RANGE_PART_REGEXP = %r{\A(?<year>((1\d|2\d)\d\d))-?(?<month>0[1-9]|1[012])-?(?<day>[0-2]\d|3[01])?\z}

    class << self
      SHORTHANDS.each do |method, range|
        define_method(method, range)
      end
    end

    def self.parse(input)
      return DateRange.new(input) if input.kind_of?(Range)
      return SHORTHANDS[input.to_sym].call if SHORTHANDS.key?(input.to_sym)

      begin_date, end_date = input.split("..")
      raise InvalidDateRangeFormat, "#{input} doesn't have a begin..end format" unless begin_date && end_date

      DateRange.new(parse_date(begin_date), parse_date(end_date, last: true))
    end

    def self.parse_date(input, last: false)
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

    def initialize(begin_date, end_date = nil)
      begin_date, end_date = begin_date.begin, begin_date.end if begin_date.kind_of?(Range)
      begin_date = begin_date.to_date if begin_date.kind_of?(Time)
      end_date = end_date.to_date if end_date.kind_of?(Time)

      raise InvalidDateRange, "Date range invalid, begin should be a date" unless begin_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, end should be a date" unless end_date.kind_of?(Date)
      raise InvalidDateRange, "Date range invalid, begin #{begin_date} is after end #{end_date}" if begin_date > end_date

      super(begin_date, end_date)
    end

    def +(other)
      raise InvalidAddition if self.end != (other.begin - 1.day)

      DateRange.new(self.begin, other.end)
    end

    def days
      @days ||= (self.end - self.begin).to_i + 1
    end

    def months
      return nil unless full_month?

      ((self.end.year - self.begin.year) * 12) + (self.end.month - self.begin.month + 1)
    end

    def quarters
      return nil unless full_quarter?

      months / 3
    end

    def years
      return nil unless full_year?

      months / 12
    end

    def one_month?
      self.begin == self.begin.at_beginning_of_month && self.end == self.begin.at_end_of_month
    end

    def one_quarter?
      self.begin == self.begin.at_beginning_of_quarter && self.end == self.begin.at_end_of_quarter
    end

    def one_year?
      self.begin == self.begin.at_beginning_of_year && self.end == self.begin.at_end_of_year
    end

    def full_month?
      self.begin == self.begin.at_beginning_of_month && self.end == self.end.at_end_of_month
    end

    def full_quarter?
      self.begin == self.begin.at_beginning_of_quarter && self.end == self.end.at_end_of_quarter
    end

    def full_year?
      self.begin == self.begin.at_beginning_of_year && self.end == self.end.at_end_of_year
    end

    def granularity
      if one_year?
        :year
      elsif one_quarter?
        :quarter
      elsif one_month?
        :month
      end
    end

    def relative_param
      @relative_param ||= SHORTHANDS.find { |key, range| self == range.call }&.first&.to_s
    end

    def to_param(relative: false)
      if relative && relative_param
        relative_param
      else
        format = full_month? ? "%Y%m" : "%Y%m%d"
        "#{self.begin.strftime(format)}..#{self.end.strftime(format)}"
      end
    end

    def to_datetime_range
      Range.new(self.begin.to_datetime.at_beginning_of_day, self.end.to_datetime.at_end_of_day)
    end

    def to_s
      "#{self.begin.strftime('%Y%m%d')}..#{self.end.strftime('%Y%m%d')}"
    end

    def previous(periods: 1)
      if granularity
        DateRange.new(self.begin - periods.send(granularity), self.begin - 1.day)
      elsif full_month?
        DateRange.new(in_groups_of(:month).first.previous(periods: periods * months).begin, self.begin - 1.day)
      else
        DateRange.new((self.begin - (periods * days).days).at_beginning_of_month, self.begin - 1.day)
      end
    end

    def next(periods: 1)
      if granularity
        DateRange.new(self.end + 1.day, (self.end + periods.send(granularity)).at_end_of_month)
      else
        DateRange.new(self.end + 1.day, (self.end + days.days).at_end_of_month)
      end
    end

    def in_groups_of(granularity, amount: 1)
      raise UnknownGranularity, "Unknown granularity #{granularity}. Valid are: month, quarter and year" unless %w[month quarter year].include?(granularity.to_s)

      [].tap do |groups|
        current_date = self.begin
        while current_date <= self.end
          end_date = amount == 1 ? current_date : (current_date + amount.send(granularity) - 1.day)
          groups << DateRange.new(
            current_date.send("at_beginning_of_#{granularity}"),
            end_date.send("at_end_of_#{granularity}")
          )
          current_date += amount.send(granularity)
        end

        groups[0] = DateRange.new(self.begin, groups.first.end) if groups.first.begin != self.begin
        if groups.last.end > self.end
          groups[groups.length - 1] = DateRange.new(groups.last.begin, self.end)
        elsif groups.last.end < self.end
          groups << DateRange.new(self.end.send("at_beginning_of_#{granularity}"), self.end)
        end
      end
    end
  end
end
