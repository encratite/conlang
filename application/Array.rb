class Array
  def *(other)
    output = []
    size.times do |i|
      left = self[i]
      other.size.times do |j|
        right = other[j]
        output << (left + right)
      end
    end
    return output
  end
end
