module Romanisation
  Replacements = {
    'a_"' => 'a',
    'e_o' => 'e',
    'k_w' => 'kw',
    'tS' => 'tx',
    'ts' => 'ts',
    'tK' => 'tl',
    'S' => 'x',
    '?' => '',
  }

  def self.romaniseXSAMPA(input)
    output = input
    Replacements.each do |key, value|
      output = output.gsub(key, value)
    end
    return output
  end
end
