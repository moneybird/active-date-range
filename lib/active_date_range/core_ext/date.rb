# frozen_string_literal: true

class Date
  # Returns the number of the quarter for this date
  #
  #   Date.new(2021, 1, 1) # => 1
  def quarter
    (month / 3.0).ceil
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
