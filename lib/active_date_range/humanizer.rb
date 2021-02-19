# frozen_string_literal: true

require "i18n"

module ActiveDateRange
  # Translates a <tt>DateRange</tt> to a human readable format. Localization and translations are
  # handled by I18n.
  #
  # Valid <tt>format</tt> parameters:
  # - <tt>short</tt> (default): Jan 1, 2021 - Jan 15, 2021
  # - <tt>long</tt>: January 12, 2021 - January 15, 2021
  # - <tt>relative</tt>: when available, returns a relative translation like "this month" or "next year".
  # - <tt>explicit</tt>: never shortens a <tt>short</tt> or <tt>long</tt> format (see below)
  #
  # Unless you use the <tt>:explicit</tt> format, the translation is as short as possible:
  #
  #   DateRange.parse("20210101..20210101").humanize # => "Jan 1, 2021"
  #   DateRange.parse("20210101..20210115").humanize # => "Jan 1 - Jan 15, 2021"
  #   DateRange.parse("20210101..20220115").humanize # => "Jan 1 2021 - Jan 15, 2022"
  #   DateRange.parse("202101..202101").humanize # => "Jan 2021"
  #   DateRange.parse("202101..202102").humanize # => "Jan - Feb 2021"
  #   DateRange.parse("202101..202202").humanize # => "Jan 2021 - Feb 2022"
  #   DateRange.parse("202101..202103").humanize # => "Q1 2021"
  #   DateRange.parse("202101..202106").humanize # => "Q1 - Q2 2021"
  #   DateRange.parse("202101..202206").humanize # => "Q1 2021 - Q2 2022"
  #   DateRange.parse("202101..202112").humanize # => "2021"
  #   DateRange.parse("202101..202212").humanize # => "2021 - 2021"
  #
  # Translations and formats are completely customizable through <tt>I18n</tt>.
  class Humanizer
    attr_reader :date_range, :format

    FORMATS = %i[short long relative explicit]

    def initialize(date_range, format: :short)
      @date_range = date_range
      raise ArgumentError, "Unknown format #{format} for humanize, valid formats: #{FORMATS.join(", ")}" unless FORMATS.include?(format)

      @format = format
    end

    def humanize
      return day_range if format == :explicit

      relative || one_day || year || quarter || month || day_range
    end

    private
      def relative
        return unless format == :relative && date_range.relative_param

        I18n.translate(date_range.relative_param, scope: %i[date relative_range])
      end

      def one_day
        return unless date_range.days == 1

        I18n.localize(date_range.begin, format: :"#{format}_day")
      end

      def year
        return unless date_range.full_year? || format == :explicit

        if date_range.one_year?
          date_range.begin.year.to_s
        else
          range(date_range.begin.year, date_range.end.year)
        end
      end

      def quarter
        return unless date_range.full_quarter? || format == :explicit

        if date_range.one_quarter?
          I18n.translate(
            "#{format}_quarter",
            scope: :date, quarter: "#{date_range.begin.quarter} #{date_range.begin.year}"
          )
        else
          begin_quarter = if date_range.same_year?
            date_range.begin.quarter
          else
            "#{date_range.begin.quarter} #{date_range.begin.year}"
          end

          range(
            I18n.translate("#{format}_quarter", scope: :date, quarter: begin_quarter),
            I18n.translate(
              "#{format}_quarter",
              scope: :date, quarter: "#{date_range.end.quarter} #{date_range.end.year}"
            )
          )
        end
      end

      def month
        return unless date_range.one_month?

        I18n.localize(date_range.begin, format: :"#{format}_month")
      end

      def day_range
        month_format = date_range.full_month? ? "month" : "day_month"
        abbr = "abbr_" if date_range.same_year?

        range(
          I18n.localize(date_range.begin, format: :"#{abbr}#{format}_#{month_format}"),
          I18n.localize(date_range.end, format: :"#{format}_#{month_format}")
        )
      end

      def range(range_begin, range_end)
        I18n.translate(:range, scope: :date, begin: range_begin, end: range_end)
      end
  end
end
