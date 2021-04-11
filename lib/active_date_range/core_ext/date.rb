# frozen_string_literal: true

class Date
  # Returns the number of the quarter for this date
  #
  #   Date.new(2021, 1, 1).quarter # => 1
  def quarter
    (month / 3.0).ceil
  end
end
