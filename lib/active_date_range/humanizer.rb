# frozen_string_literal: true

require "i18n"

module ActiveDateRange
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
