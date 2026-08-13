# frozen_string_literal: true

module ActiveDateRange
  module Validators
    class DateRangeValidator < ActiveModel::EachValidator
      include ResolveValue

      DURATION_OPTIONS = %i[minimum_duration maximum_duration exact_duration duration].freeze
      GRANULARITY_MAP = {
        month: :full_month?,
        quarter: :full_quarter?,
        year: :full_year?,
        week: :full_week?
      }.freeze
      START_ALIGNMENT_MAP = {
        beginning_of_month: :begin_at_beginning_of_month?,
        beginning_of_quarter: :begin_at_beginning_of_quarter?,
        beginning_of_year: :begin_at_beginning_of_year?,
        beginning_of_week: :begin_at_beginning_of_week?
      }.freeze
      END_ALIGNMENT_MAP = {
        end_of_month: ->(r) { r.end == r.end.at_end_of_month },
        end_of_quarter: ->(r) { r.end == r.end.at_end_of_quarter },
        end_of_year: ->(r) { r.end == r.end.at_end_of_year },
        end_of_week: ->(r) { r.end == r.end.at_end_of_week }
      }.freeze

      def validate_each(record, attribute, value)
        unless value.is_a?(ActiveDateRange::DateRange)
          record.errors.add(attribute, :not_a_date_range, **options.except(*known_options))
          return
        end

        validate_bounded(record, attribute, value)
        validate_duration(record, attribute, value)
        validate_full_periods_of(record, attribute, value)
        validate_starts_on(record, attribute, value)
        validate_ends_on(record, attribute, value)
        validate_covers(record, attribute, value)
      end

      private
        def known_options
          DURATION_OPTIONS + %i[bounded full_periods_of starts_on ends_on covers message]
        end

        def validate_bounded(record, attribute, value)
          return unless options[:bounded]

          if value.boundless?
            record.errors.add(attribute, :unbounded, **options.except(*known_options))
          end
        end

        def validate_duration(record, attribute, value)
          if options[:duration]
            range = resolve_value(record, options[:duration])
            validate_minimum_duration(record, attribute, value, range.begin) if range.begin
            validate_maximum_duration(record, attribute, value, range.end) if range.end
          end

          if options[:minimum_duration]
            duration = resolve_value(record, options[:minimum_duration])
            validate_minimum_duration(record, attribute, value, duration)
          end

          if options[:maximum_duration]
            duration = resolve_value(record, options[:maximum_duration])
            validate_maximum_duration(record, attribute, value, duration)
          end

          if options[:exact_duration]
            duration = resolve_value(record, options[:exact_duration])
            validate_exact_duration(record, attribute, value, duration)
          end
        end

        def validate_minimum_duration(record, attribute, value, duration)
          unless meets_minimum_duration?(value, duration)
            record.errors.add(attribute, :duration_too_short,
              duration: humanize_duration(duration),
              **options.except(*known_options))
          end
        end

        def validate_maximum_duration(record, attribute, value, duration)
          unless meets_maximum_duration?(value, duration)
            record.errors.add(attribute, :duration_too_long,
              duration: humanize_duration(duration),
              **options.except(*known_options))
          end
        end

        def validate_exact_duration(record, attribute, value, duration)
          unless meets_minimum_duration?(value, duration) && meets_maximum_duration?(value, duration)
            record.errors.add(attribute, :wrong_duration,
              duration: humanize_duration(duration),
              **options.except(*known_options))
          end
        end

        # Calendar-aware: Feb 1..Feb 28 with 1.month → begin + 1.month - 1.day = Feb 28 <= Feb 28 ✓
        def meets_minimum_duration?(range, duration)
          return true if range.boundless?
          range.begin + duration - 1.day <= range.end
        end

        # Calendar-aware: Jan 1..Dec 31 with 1.year → begin + 1.year - 1.day = Dec 31 >= Dec 31 ✓
        def meets_maximum_duration?(range, duration)
          return false if range.boundless?
          range.begin + duration - 1.day >= range.end
        end

        def validate_full_periods_of(record, attribute, value)
          return unless options[:full_periods_of]

          period = options[:full_periods_of].to_sym
          method = GRANULARITY_MAP[period]

          unless method && value.respond_to?(method) && value.public_send(method)
            record.errors.add(attribute, :not_full_periods,
              period: period,
              **options.except(*known_options))
          end
        end

        def validate_starts_on(record, attribute, value)
          return unless options[:starts_on]

          alignment = options[:starts_on].to_sym
          method = START_ALIGNMENT_MAP[alignment]

          unless method && value.respond_to?(method) && value.public_send(method)
            record.errors.add(attribute, :misaligned_start,
              alignment: alignment.to_s.tr("_", " "),
              **options.except(*known_options))
          end
        end

        def validate_ends_on(record, attribute, value)
          return unless options[:ends_on]

          alignment = options[:ends_on].to_sym
          unless value.end.nil?
            checker = END_ALIGNMENT_MAP[alignment]

            return if checker&.call(value)
          end

          record.errors.add(attribute, :misaligned_end,
            alignment: alignment.to_s.tr("_", " "),
            **options.except(*known_options))
        end

        def validate_covers(record, attribute, value)
          return unless options[:covers]

          date = resolve_value(record, options[:covers])

          unless value.cover?(date)
            record.errors.add(attribute, :does_not_cover,
              date: date,
              **options.except(*known_options))
          end
        end

        def humanize_duration(duration)
          return duration.inspect unless duration.respond_to?(:parts)

          duration.parts.map do |unit, amount|
            label = amount == 1 ? unit.to_s.singularize : unit.to_s.pluralize
            "#{amount} #{label}"
          end.join(", ")
        end
    end
  end
end
