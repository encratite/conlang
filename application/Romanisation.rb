module Romanisation
  Replacements = {
    'tS' => 'c',
    'ts' => 'z',
    'S' => 'x',
    '?' => '',
    '4' => 'r',
  }

  def self.romaniseXSAMPA(input)
    output = input
    Replacements.each do |key, value|
      output = output.gsub(key, value)
    end
    return output
  end
end
