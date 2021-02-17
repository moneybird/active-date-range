# frozen_string_literal: true

class Integer
  def quarters
    self * 3.months
  end

  alias quarter quarters
end
