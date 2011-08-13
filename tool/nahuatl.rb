require 'nil/file'

$: << '..'

require 'application/Generator'

replacements = {
  'ch' => 'tS',
  'tl' => 'tK',
  'hu' => 'w',
  'tz' => 'ts',
  'qu' => 'k_w',
  'cu' => 'k_w',
  'c' => 'k',
  'y' => 'j',
  #ignore glottal stops
  #'h' => '?',
  'h' => '',
  'x' => 'S',
  'z' => 's',
  #???
  'u' => 'o',
  'ia' => 'ja',
  'ie' => 'je',
  'io' => 'jo',
}

lines = Nil.readLines('../data/nahuatl')
lexicon = []
lines.each do |line|
  match = line.match(/.+? :: ([a-z]+)/)
  if match == nil
    next
  end
  word = match[1]
  processedWord = word
  replacements.each do |key, value|
    processedWord = processedWord.gsub(key, value)
  end
  ('a'..'z').each do |letter|
    processedWord = processedWord.gsub(letter + letter, letter)
  end
  #puts "#{word} => #{processedWord}"
  lexicon << processedWord
end

isValid = lambda do |left, right|
  output = false
  lexicon.each do |word|
    Generator::Vowels.each do |vowel|
      if word.index(left + vowel + right) != nil
        #puts "Hit for #{left}, #{right} in #{word}"
        output = true
        break
      end
    end
    break if output
  end
  output
end

Generator::InitialConsonants.each do |a|
  next if a == '?'
  Generator::ExtendingConsonants.each do |b|
    if !isValid.call(a, b)
      #puts "Invalid basic combination: #{a}, #{b}"
      puts "['#{a}', '#{b}'],"
    end
  end
end

Generator::ExtendingConsonants.each do |a|
  Generator::ExtendingConsonants.each do |b|
    if !isValid.call(a, b)
      #puts "Invalid extended combination: #{a}, #{b}"
      puts "['#{a}', '#{b}'],"
    end
  end
end
