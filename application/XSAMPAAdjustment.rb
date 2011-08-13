module XSAMPAAdjustment
  Replacements = {
    'a' => 'a_"',
    'e' => 'e_o',
  }

  def self.adjust(input)
    output = input
    Replacements.each do |target, replacement|
      output = output.gsub(target, replacement)
    end
    return output
  end
end
