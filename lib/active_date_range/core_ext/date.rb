# frozen_string_literal: true

class Date
  # Returns the number of the quarter for this date
  #
  #   Date.new(2021, 1, 1) # => 1
  def quarter
    case month
    when 1..3
      1
    when 4..6
      2
    when 7..9
      3
    when 10..12
      4
    end
  end

  # Shifts the date to the next quarter
  #
  #   Date.new(2021, 1, 1).next_quarter # => Date.new(2021, 4, 1)
  def next_quarter(n = 1)
    self >> (n * 3)
  end

  # Shifts the date to the previous quarter
  #
  #   Date.new(2021, 4, 1).next_quarter # => Date.new(2021, 1, 1)
  def prev_quarter(n = 1)
    self << (n * 3)
  end
end
