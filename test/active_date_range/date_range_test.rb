# frozen_string_literal: true

require "test_helper"

class ActiveDateRangeDateRangeTest < ActiveSupport::TestCase
  def described_class
    ActiveDateRange::DateRange
  end

  def test_initialize
    range = described_class.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31))
    assert_kind_of ActiveDateRange::DateRange, range
    assert_kind_of Range, range
    assert_kind_of Date, range.begin
    assert_kind_of Date, range.end
  end

  def test_initialize_range
    assert_kind_of Range, described_class.new(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
  end

  def test_initialize_array
    assert_kind_of Range, described_class.new([Date.new(2021, 1, 1), Date.new(2021, 12, 31)])
  end

  def test_date_and_duration
    assert_equal described_class.new(Date.new(2021, 1, 1), Date.new(2021, 1, 15)), described_class.from_date_and_duration(Date.new(2021, 1, 1), 15)
    assert_equal described_class.new(Date.new(2021, 1, 1), Date.new(2021, 1, 31)), described_class.from_date_and_duration(Date.new(2021, 1, 1), :month)
    assert_equal described_class.new(Date.new(2021, 1, 1), Date.new(2021, 3, 31)), described_class.from_date_and_duration(Date.new(2021, 1, 1), :quarter)
    assert_equal described_class.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31)), described_class.from_date_and_duration(Date.new(2021, 1, 1), :year)
  end

  def test_initialize_no_dates
    assert_raises(ActiveDateRange::InvalidDateRange) { described_class.new(1, 2) }
    assert_raises(ActiveDateRange::InvalidDateRange) { described_class.new(Date.new(2021, 1, 1), 2) }
    assert_raises(ActiveDateRange::InvalidDateRange) { described_class.new(1, Date.new(2021, 12, 31)) }
  end

  def test_initialize_end_before_start
    assert_raises(ActiveDateRange::InvalidDateRange) { described_class.new(Date.new(2021, 12, 31), Date.new(2021, 1, 1)) }
  end

  def test_shorthands
    assert_equal Date.today.all_month, described_class.this_month
    assert_equal 1.month.ago.to_date.all_month, described_class.prev_month
    assert_equal 1.month.from_now.to_date.all_month, described_class.next_month
    assert_equal Date.today.all_quarter, described_class.this_quarter
    assert_equal 3.months.ago.to_date.all_quarter, described_class.prev_quarter
    assert_equal 3.months.from_now.to_date.all_quarter, described_class.next_quarter
    assert_equal Date.today.all_year, described_class.this_year
    assert_equal 12.months.ago.to_date.all_year, described_class.prev_year
    assert_equal 12.months.from_now.to_date.all_year, described_class.next_year
    assert_equal Date.today.all_week, described_class.this_week
    assert_equal 1.week.ago.to_date.all_week, described_class.prev_week
    assert_equal 1.week.from_now.to_date.all_week, described_class.next_week
  end

  def test_parse
    assert_equal described_class.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31)), described_class.parse(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
    assert_equal described_class.new(Date.new(2021, 1, 1), Date.new(2021, 12, 31)), described_class.parse(Date.new(2021, 1, 1)..Date.new(2021, 12, 31))
    assert_equal described_class.new(Date.new(2013, 5, 1), Date.new(2013, 9, 1).at_end_of_month), described_class.parse("201305..201309")
    assert_equal described_class.new(Date.new(2013, 5, 1), Date.new(2013, 9, 1).at_end_of_month), described_class.parse("2013-05..2013-09")
    assert_equal described_class.new(Date.new(2014, 4, 15), Date.new(2014, 5, 23)), described_class.parse("20140415..20140523")
    assert_equal described_class.new(Date.new(2014, 4, 15), Date.new(2014, 5, 31)), described_class.parse("20140415..201405")
    assert_equal described_class.new(Date.new(2016, 5, 23), Date.new(2016, 5, 23)), described_class.parse("2016-05-23..2016-05-23")
    assert_equal described_class.new(Date.new(2014, 4, 1), Date.new(2014, 5, 15)), described_class.parse("201404..20140515")
    assert_equal described_class.new(Date.new(2014, 4, 1), Date.new(2014, 5, 15)), described_class.parse("2014-04..2014-05-15")
    assert_equal described_class.this_month, described_class.parse("this_month")
    assert_equal described_class.prev_month, described_class.parse("prev_month")
    assert_equal described_class.next_month, described_class.parse("next_month")
    assert_equal described_class.this_quarter, described_class.parse("this_quarter")
    assert_equal described_class.prev_quarter, described_class.parse("prev_quarter")
    assert_equal described_class.next_quarter, described_class.parse("next_quarter")
    assert_equal described_class.this_year, described_class.parse("this_year")
    assert_equal described_class.prev_year, described_class.parse("prev_year")
    assert_equal described_class.next_year, described_class.parse("next_year")
    assert_equal described_class.this_week, described_class.parse("this_week")
    assert_equal described_class.prev_week, described_class.parse("prev_week")
    assert_equal described_class.next_week, described_class.parse("next_week")
    (Date.new(2021, 1, 1)..Date.new(2021, 12, 31)).to_a.each do |date|
      assert_equal described_class.new(date, date), described_class.parse("#{date.strftime("%Y%m%d")}..#{date.strftime("%Y%m%d")}")
    end
    %w[2012..2013 2013011..2013051 foobar month 20-1301..20-1305 20160925..20160931].each do |format|
      assert_raises(ActiveDateRange::InvalidDateRangeFormat) { described_class.parse(format) }
    end
  end

  def test_addition
    a = described_class.new(Date.new(2021, 1, 1)..Date.new(2021, 1, 31))
    b = described_class.new(Date.new(2021, 2, 1)..Date.new(2021, 2, 28))
    c = described_class.new(Date.new(2021, 3, 1)..Date.new(2021, 3, 31))
    assert_equal Date.new(2021, 1, 1)..Date.new(2021, 2, 28), a + b

    a = described_class.parse("20210419..20210425")
    b = described_class.parse("20210426..20210502")
    assert_equal described_class.parse("20210419..20210502"), a + b

    assert_raises(ActiveDateRange::InvalidAddition) { a + c }
  end

  def test_sort
    a = described_class.parse("202001..202001")
    b = described_class.parse("202002..202002")
    assert_equal([a, b], [b, a].sort)
  end

  def test_begin_at_beginning_of_month
    assert described_class.parse("202001..202001").begin_at_beginning_of_month?
    assert_not described_class.parse("20200102..20200102").begin_at_beginning_of_month?
  end

  def test_begin_at_beginning_of_quarter
    assert described_class.parse("202001..202001").begin_at_beginning_of_quarter?
    assert described_class.parse("202004..202006").begin_at_beginning_of_quarter?
    assert described_class.parse("202007..202009").begin_at_beginning_of_quarter?
    assert described_class.parse("202010..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202002..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202003..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202005..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202006..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202008..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202009..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202011..202012").begin_at_beginning_of_quarter?
    assert_not described_class.parse("202012..202012").begin_at_beginning_of_quarter?
  end

  def test_begin_at_beginning_of_year
    assert described_class.parse("202001..202001").begin_at_beginning_of_year?
    assert_not described_class.parse("202002..202002").begin_at_beginning_of_year?
  end

  def test_begin_at_beginning_of_week
    assert described_class.parse("20210419..20210425").begin_at_beginning_of_week?
    assert_not described_class.parse("20210418..20210424").begin_at_beginning_of_week?
    assert_not described_class.parse("20210420..20210426").begin_at_beginning_of_week?
  end

  def test_one_methods
    assert described_class.this_month.one_month?
    assert described_class.this_quarter.one_quarter?
    assert described_class.this_year.one_year?
    assert described_class.this_week.one_week?

    assert described_class.parse("202001..202003").one_quarter?
    assert described_class.parse("202101..202103").one_quarter?
    assert described_class.parse("202104..202106").one_quarter?
    assert described_class.parse("202107..202109").one_quarter?
    assert described_class.parse("202110..202112").one_quarter?

    assert described_class.parse("202001..202012").one_year?
    assert described_class.parse("202101..202112").one_year?

    assert_not described_class.this_month.one_quarter?
    assert_not described_class.this_month.one_year?

    assert_not described_class.this_quarter.one_month?
    assert_not described_class.this_quarter.one_year?

    assert_not described_class.this_year.one_month?
    assert_not described_class.this_year.one_quarter?

    assert_not (described_class.this_month + described_class.next_month).one_month?
    assert_not (described_class.this_quarter + described_class.next_quarter).one_quarter?
    assert_not (described_class.this_year + described_class.next_year).one_year?
  end

  def test_full_methods
    assert described_class.this_month.full_month?
    assert described_class.this_quarter.full_month?
    assert described_class.this_quarter.full_quarter?
    assert described_class.this_year.full_month?
    assert described_class.this_year.full_quarter?
    assert described_class.this_year.full_year?

    assert described_class.new(Date.new(2020, 1, 1), Date.new(2020, 9, 30)).full_months?
    assert described_class.new(Date.new(2020, 1, 1), Date.new(2020, 9, 30)).full_quarters?
    assert described_class.new(Date.new(2020, 1, 1), Date.new(2021, 12, 31)).full_years?

    assert_not described_class.new(Date.new(2020, 1, 1), Date.new(2020, 9, 29)).full_month?
    assert_not described_class.new(Date.new(2020, 1, 1), Date.new(2020, 9, 29)).full_quarter?
    assert_not described_class.new(Date.new(2020, 1, 1), Date.new(2020, 12, 30)).full_year?
  end

  def test_granularity
    assert_equal :month, described_class.this_month.granularity
    assert_equal :quarter, described_class.this_quarter.granularity
    assert_equal :year, described_class.this_year.granularity
    assert_equal :week, described_class.this_week.granularity
  end

  def test_days
    assert_equal 1, described_class.parse("20210101..20210101").days
    assert_equal 31, described_class.parse("202101..202101").days
    assert_equal 365, described_class.parse("202101..202112").days
    assert_equal 7, described_class.parse("this_week").days
  end

  def test_same_year
    assert described_class.parse("202001..202012").same_year?
    assert_not described_class.parse("202001..202112").same_year?
  end

  def test_current
    assert described_class.this_month.current?
    assert described_class.this_quarter.current?
    assert described_class.this_year.current?
    assert_not described_class.prev_month.current?
    assert_not described_class.prev_quarter.current?
    assert_not described_class.prev_year.current?
    assert_not described_class.next_month.current?
    assert_not described_class.next_quarter.current?
    assert_not described_class.next_year.current?
  end

  def test_this_month
    assert described_class.this_month.this_month?
    assert_not described_class.prev_month.this_month?
    assert_not described_class.next_month.this_month?
  end

  def test_this_quarter
    assert described_class.this_quarter.this_quarter?
    assert_not described_class.prev_quarter.this_quarter?
    assert_not described_class.next_quarter.this_quarter?
  end

  def test_this_year
    assert described_class.this_year.this_year?
    assert_not described_class.prev_year.this_year?
    assert_not described_class.next_year.this_year?
  end

  def test_to_param
    assert_equal "202001..202001", described_class.parse("202001..202001").to_param
    assert_equal "202001..202012", described_class.parse("202001..202012").to_param(relative: false)
    assert_equal "20200101..20201210", described_class.parse("20200101..20201210").to_param

    %w[
      this_month prev_month next_month this_quarter prev_quarter next_quarter
      this_year prev_year next_year this_week prev_week next_week
    ].each do |relative|
      assert_equal relative, described_class.parse(relative).to_param
    end
  end

  def test_to_datetime_range
    assert_equal DateTime.new(2021, 1, 1)..DateTime.new(2021, 12, 31).at_end_of_day, described_class.parse("202101..202112").to_datetime_range
  end

  def test_previous
    assert_equal described_class.prev_month, described_class.this_month.previous
    assert_equal described_class.prev_quarter, described_class.this_quarter.previous
    assert_equal described_class.prev_year, described_class.this_year.previous
    assert_equal described_class.prev_week, described_class.this_week.previous
    assert_equal described_class.parse("201204..201302"), described_class.parse("201303..201401").previous
    assert_equal described_class.parse("201303..201401").months, described_class.parse("201303..201401").previous.months
    assert_equal described_class.parse("201201..201312"), described_class.parse("201401..201406").previous(4)
    assert_equal 4 * described_class.parse("201401..201406").months, described_class.parse("201401..201406").previous(4).months
    assert_equal described_class.parse("201304..201406"), described_class.parse("201407..201509").previous
    assert_equal described_class.parse("201407..201509").months, described_class.parse("201407..201509").previous.months
    assert_equal described_class.parse("20210412..20210418"), described_class.parse("20210419..20210425").previous
    assert_equal described_class.parse("20210413..20210419"), described_class.parse("20210420..20210426").previous
    assert_equal described_class.parse("20210329..20210411"), described_class.parse("20210412..20210425").previous
    assert_equal described_class.parse("20210328..20210410"), described_class.parse("20210411..20210424").previous
  end

  def test_next
    assert_equal described_class.parse("201302..201302"), described_class.parse("201301..201301").next
    assert_equal described_class.parse("201407..201407"), described_class.parse("201406..201406").next
    assert_equal described_class.parse("201408..201408"), described_class.parse("201407..201407").next
    assert_equal described_class.parse("201409..201409"), described_class.parse("201408..201408").next
    assert_equal described_class.parse("201407..201410"), described_class.parse("201406..201406").next(4)
    assert_equal described_class.parse("201304..201306"), described_class.parse("201301..201303").next
    assert_equal described_class.parse("201401..201412"), described_class.parse("201301..201312").next
    assert_equal described_class.parse("201403..201502"), described_class.parse("201303..201402").next
    assert_equal described_class.parse("201510..201612"), described_class.parse("201407..201509").next
    assert_equal described_class.parse("201407..201509").months, described_class.parse("201407..201509").next.months
    assert_equal described_class.parse("202301..202412"), described_class.parse("202101..202212").next
    assert_equal described_class.parse("202501..202612"), described_class.parse("202301..202412").next
    assert_equal described_class.next_week, described_class.this_week.next
  end

  def test_in_groups_of
    assert_raises(ActiveDateRange::UnknownGranularity) { described_class.this_year.in_groups_of(:halve_year) }
    assert_equal(
      [
        described_class.parse("202101..202101"),
        described_class.parse("202102..202102"),
        described_class.parse("202103..202103"),
        described_class.parse("202104..202104"),
        described_class.parse("202105..202105"),
        described_class.parse("202106..202106"),
        described_class.parse("202107..202107"),
        described_class.parse("202108..202108"),
        described_class.parse("202109..202109"),
        described_class.parse("202110..202110"),
        described_class.parse("202111..202111"),
        described_class.parse("202112..202112")
      ],
      described_class.parse("202101..202112").in_groups_of(:month)
    )
    assert_equal(
      [
        described_class.parse("202101..202101"),
        described_class.parse("202102..202102"),
        described_class.parse("202103..202103"),
        described_class.parse("202104..202104"),
        described_class.parse("202105..202105"),
        described_class.parse("202106..202106")
      ],
      described_class.parse("202101..202106").in_groups_of(:month)
    )
    assert_equal(
      [
        described_class.parse("202101..202101"),
        described_class.parse("202102..202102"),
        described_class.parse("202103..202103")
      ],
      described_class.parse("202101..202103").in_groups_of(:month)
    )
    assert_equal(
      [
        described_class.parse("202101..202101"),
      ],
      described_class.parse("202101..202101").in_groups_of(:month)
    )
    assert_equal(
      [
        described_class.parse("20200115..20200131"),
        described_class.parse("202002..202002"),
        described_class.parse("20200301..20200315"),
      ],
      described_class.parse("20200115..20200315").in_groups_of(:month)
    )
    assert_equal(
      [
        described_class.parse("201201..201206"),
        described_class.parse("201207..201212"),
        described_class.parse("201301..201306"),
        described_class.parse("201307..201312"),
        described_class.parse("201401..201406")
      ],
      described_class.parse("201201..201406").in_groups_of(:month, amount: 6)
    )

    assert_equal(
      [
        described_class.parse("202101..202103"),
        described_class.parse("202104..202106"),
        described_class.parse("202107..202109"),
        described_class.parse("202110..202112")
      ],
      described_class.parse("202101..202112").in_groups_of(:quarter)
    )
    assert_equal(
      [
        described_class.parse("202101..202103"),
      ],
      described_class.parse("202101..202103").in_groups_of(:quarter)
    )
    assert_equal(
      [
        described_class.parse("202101..202101"),
      ],
      described_class.parse("202101..202101").in_groups_of(:quarter)
    )

    assert_equal(
      [
        described_class.parse("202101..202112"),
        described_class.parse("202201..202212")
      ],
      described_class.parse("202101..202212").in_groups_of(:year)
    )
    assert_equal(
      [
        described_class.parse("202005..202012"),
        described_class.parse("202101..202112")
      ],
      described_class.parse("202005..202112").in_groups_of(:year)
    )
  end

  def test_months
    assert_equal 1, described_class.parse("202101..202101").months
    assert_equal 2, described_class.parse("202101..202102").months
    assert_equal 3, described_class.parse("202101..202103").months
    assert_equal 4, described_class.parse("202101..202104").months
    assert_equal 5, described_class.parse("202101..202105").months
    assert_equal 6, described_class.parse("202101..202106").months
    assert_equal 7, described_class.parse("202101..202107").months
    assert_equal 8, described_class.parse("202101..202108").months
    assert_equal 9, described_class.parse("202101..202109").months
    assert_equal 10, described_class.parse("202101..202110").months
    assert_equal 11, described_class.parse("202101..202111").months
    assert_equal 12, described_class.parse("202101..202112").months
    assert_equal 13, described_class.parse("202101..202201").months
    assert_equal 26, described_class.parse("202101..202302").months
    assert_equal 44, described_class.parse("202101..202408").months
    assert_equal 51, described_class.parse("202107..202509").months
    assert_nil described_class.parse("20210101..20210215").months
  end

  def test_quarters
    assert_equal 1, described_class.parse("202101..202103").quarters
    assert_equal 2, described_class.parse("202101..202106").quarters
    assert_equal 3, described_class.parse("202101..202109").quarters
    assert_equal 4, described_class.parse("202101..202112").quarters
    assert_nil described_class.parse("202101..202111").quarters
  end

  def test_years
    assert_equal 1, described_class.parse("202101..202112").years
    assert_equal 2, described_class.parse("202101..202212").years
    assert_nil described_class.parse("202101..202111").years
  end

  def test_weeks
    assert_equal 1, described_class.parse("20210419..20210425").weeks
    assert_equal 2, described_class.parse("20210412..20210425").weeks
    assert_nil described_class.parse("20210419..20210424").weeks
  end

  def test_humanize
    assert_equal "Q1 2021", described_class.parse("202101..202103").humanize
    assert_equal "quarter 1 2021", described_class.parse("202101..202103").humanize(format: :long)
  end

  def test_intersection
    assert_equal described_class.parse("202103..202104"), described_class.parse("202101..202104").intersection(described_class.parse("202103..202107"))
    assert_equal described_class.parse("202103..202104"), described_class.parse("202101..202110").intersection(described_class.parse("202103..202104"))
    assert_equal described_class.parse("202103..202104"), described_class.parse("202103..202107").intersection(described_class.parse("202101..202104"))
    assert_equal described_class.parse("20210401..20210406"), described_class.parse("202101..20210406").intersection(described_class.parse("20210401..202107"))
    assert_nil described_class.parse("202101..202104").intersection(described_class.parse("202105..202107"))
    assert_nil described_class.parse("202105..202107").intersection(described_class.parse("202101..202104"))
  end

  def test_boundless
    boundless = described_class.new(Date.new(2021, 1, 1), nil)

    assert_nil boundless.end
    assert_equal false, boundless.one_month?
    assert_equal false, boundless.one_quarter?
    assert_equal false, boundless.one_year?
    assert_equal false, boundless.full_month?
    assert_equal false, boundless.full_quarter?
    assert_equal false, boundless.full_year?
    assert_equal "20210101..", boundless.to_param
    assert boundless.after?(Date.new(2020, 1, 1))
    assert_not boundless.after?(Date.new(2021, 3, 1))
    assert_not boundless.before?(Date.new(2020, 3, 1))
    assert_not boundless.before?(Date.new(2021, 3, 1))
    assert_nil boundless.granularity
    assert_equal "Jan 01, 2021 - ∞", boundless.humanize
    assert_equal boundless, described_class.parse("20210101..")
    assert_equal(
      described_class.parse("202101..202112").in_groups_of(:month),
      boundless.in_groups_of(:month).take(12).to_a
    )
    assert_raises(ActiveDateRange::BoundlessRangeError) { boundless.next }
    assert_raises(ActiveDateRange::BoundlessRangeError) { boundless.previous }
  end

  def test_boundless_begin
    boundless = described_class.new(nil, Date.new(2021, 5, 1))

    assert_nil boundless.begin
    assert_equal false, boundless.one_month?
    assert_equal false, boundless.one_quarter?
    assert_equal false, boundless.one_year?
    assert_equal false, boundless.full_month?
    assert_equal false, boundless.full_quarter?
    assert_equal false, boundless.full_year?
    assert_equal "..20210501", boundless.to_param
    assert_not boundless.after?(Date.new(2021, 1, 1))
    assert_not boundless.after?(Date.new(2021, 6, 1))
    assert boundless.before?(Date.new(2021, 6, 1))
    assert_not boundless.before?(Date.new(2021, 3, 1))
    assert_nil boundless.granularity
    assert_equal "∞ - May 01, 2021", boundless.humanize
    assert_equal boundless, described_class.parse("..20210501")
    assert_raises(ActiveDateRange::BoundlessRangeError) { boundless.in_groups_of(:month) }
    assert_raises(ActiveDateRange::BoundlessRangeError) { boundless.next }
    assert_raises(ActiveDateRange::BoundlessRangeError) { boundless.previous }
  end

  def test_include
    assert described_class.this_year.include?(Date.current)
    assert described_class.this_year.include?(Date.current.at_beginning_of_year)
    assert described_class.this_year.include?(Date.current.at_end_of_year)
    assert_not described_class.prev_year.include?(Date.current)
    assert_not described_class.this_year.include?(Date.current.at_beginning_of_year - 1.day)
    assert_not described_class.this_year.include?(Date.current.at_end_of_year + 1.day)
  end

  def test_stretch_to_end_of_month
    assert_equal described_class.parse("202101..202101"), described_class.parse("202101..202101").stretch_to_end_of_month
    assert_equal described_class.parse("202101..202101"), described_class.parse("202101..").stretch_to_end_of_month
    assert_equal described_class.parse("202101..202101"), described_class.parse("20210101..20210115").stretch_to_end_of_month
    assert_equal described_class.parse("202101..202103"), described_class.parse("20210101..20210301").stretch_to_end_of_month
  end

  def test_exceeds?
    assert described_class.parse("202101..202101").exceeds?(1.week)
    assert described_class.parse("202101..202106").exceeds?(3.months)
    assert_not described_class.parse("202101..202101").exceeds?(1.month)
  end
end
