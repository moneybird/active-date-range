# frozen_string_literal: true

class Date
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

  def next_quarter(n = 1)
    self >> (n * 3)
  end

  def prev_quarter(n = 1)
    self << (n * 3)
  end
end
