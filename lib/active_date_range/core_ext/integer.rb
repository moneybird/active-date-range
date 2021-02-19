# frozen_string_literal: true

class Integer
  # Returns Duration instance matching the number of quarters provided
  #
  #   2.quarters # => 6 months
  def quarters
    self * 3.months
  end

  alias quarter quarters
end
