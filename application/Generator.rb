require 'set'

require 'nil/random'

require 'application/Array'
require 'application/Nahuatl'

module Generator
  Vowels = [
    'a',
    'i',
    'o',
    'e',
  ]

  InitialConsonants = [
    'k_w',

    'p',
    't',
    'k',

    'j',
    'w',

    '?',
  ]

  ExtendingConsonants = [
    'm',
    'n',

    'l',

    'tS',
    'ts',
    'tK',

    's',
    'S',
  ]

  Consonants = ExtendingConsonants + InitialConsonants
  Neutral = ['']

  SyllableCounts = [
    1,
    1,
    2,
    2,
  ]

  def self.loadLexicon
    consonantVowelFrequencies, finalConsonantFrequencies, consonantPairs = Nahuatl.loadLexiconData
    initialConsonantFrequencies = {}
    extendingConsonantFrequencies = {}
    consonantVowelFrequencies.each do |segments, frequency|
      consonant, vowel = segments
      if InitialConsonants.include?(consonant)
        initialConsonantFrequencies[segments] = frequency
      end
      if ExtendingConsonants.include?(consonant)
        extendingConsonantFrequencies[segments] = frequency
      end
    end
    initialSyllables = []
    initialSyllablesScale = Nil::RandomScale.new
    initialConsonantFrequencies.each do |segments, frequency|
      consonant, vowel = segments
      string = consonant + vowel
      initialSyllablesScale.add(string, frequency)
      initialSyllables << segments
    end
    extendingSyllables = []
    extendingSyllablesScale = Nil::RandomScale.new
    extendingConsonantFrequencies.each do |segments, frequency|
      consonant, vowel = segments
      string = consonant + vowel
      extendingSyllablesScale.add(string, frequency)
      extendingSyllables << segments
    end
    finalConsonants = []
    finalConsonantsScale = Nil::RandomScale.new
    finalConsonantFrequencies.each do |consonant, frequency|
      finalConsonantsScale.add(consonant, frequency)
      finalConsonants << consonant
    end
    simpleMonosyllables = initialSyllables.map { |a, b| a + b } * Neutral
    complexMonosyllables = []
    initialSyllables.each do |initialSyllable|
      initialConsonant, initialVowel = initialSyllable
      finalConsonants.each do |finalConsonant|
        pair = initialConsonant, finalConsonant
        next if initialConsonant != '?' && !consonantPairs.include?(pair)
        string = initialConsonant + initialVowel + finalConsonant
        complexMonosyllables << string
      end
    end
    simpleBisyllables = []
    initialSyllables.each do |initialSyllable|
      initialConsonant, initialVowel = initialSyllable
      extendingSyllables.each do |extendingSyllable|
        extendingConsonant, extendingVowel = extendingSyllable
        pair = initialConsonant, extendingConsonant
        next if initialConsonant != '?' && !consonantPairs.include?(pair)
        string = initialConsonant + initialVowel + extendingConsonant + extendingVowel
        simpleBisyllables << string
      end
    end
    complexBisyllables = []
    initialSyllables.each do |initialSyllable|
      initialConsonant, initialVowel = initialSyllable
      extendingSyllables.each do |extendingSyllable|
        extendingConsonant, extendingVowel = extendingSyllable
        pair = initialConsonant, extendingConsonant
        next if initialConsonant != '?' && !consonantPairs.include?(pair)
        finalConsonants.each do |finalConsonant|
          pair = extendingConsonant, finalConsonant
          next if !consonantPairs.include?(pair)
          string = initialConsonant + initialVowel + extendingConsonant + extendingVowel + finalConsonant
          complexBisyllables << string
        end
      end
    end
    words = [
      simpleMonosyllables,
      complexMonosyllables,
      simpleBisyllables,
      complexBisyllables,
    ]
    syllables = initialSyllables, extendingSyllables, finalConsonants
    scales = [initialSyllablesScale, extendingSyllablesScale, finalConsonantsScale]
    return syllables, scales, words
  end

  def self.totalWordCount
    count = 0
    Words.each do |wordClass|
      count += wordClass.size
    end
    return count
  end

  def self.printClassSizes
    puts "Class sizes:"
    Generator::Words.each do |words|
      puts words.size
    end
  end

  def self.printWordCount
    puts "Total word count: #{Generator.totalWordCount}"
  end

  def self.generateWord(priority)
    output = InitialSyllableScale.get
    case priority
    when 0
    when 1
      output += FinalConsonantsScale.get
    when 2
      output += ExtendingSyllablesScale.get
    when 3
      output += ExtendingSyllablesScale.get + FinalConsonantsScale.get
    else
      raise "Invalid priority: #{priority}"
    end
    return output
  end

  def self.describe
    puts "Vowels: #{Vowels.size}"
    puts "Consonants: #{Consonants.size}"
    self.printClassSizes
    self.printWordCount
  end

  def self.noise(syllableCount)
    generatedWords = []
    scale = Nil::RandomScale.new
    weights = [3, 2, 2, 1]
    Words.size.times do |i|
      scale.add(i, weights[i])
    end
    while syllableCount > 0
      priority = scale.get
      currentSyllableCount = SyllableCounts[priority]
      if currentSyllableCount > syllableCount
        next
      end
      syllableCount -= currentSyllableCount
      generatedWords << self.generateWord(priority)
    end
    return generatedWords.join(' ')
  end

  def self.getPriority(word)
    priority = 0
    Words.each do |wordClass|
      if wordClass.include?(word)
        return priority
      end
      priority += 1
    end
    return nil
  end

  def self.generateUnusedWord(usedWords, priority)
    attempts = 100
    attempts.times do
      word = self.generateWord(priority)
      next if usedWords.include?(word) || !Words[priority].include?(word)
      return word
    end
    unusedWords = Generator::Words[priority].reject do |word|
      usedWords.include?(word)
    end
    if unusedWords.empty?
      return nil
    end
    word = unusedWords[rand(unusedWords.size)]
    return word
  end

  def self.getSyllableStrings(input)
    output = input.map do |consonant, vowel|
      consonant + vowel
    end
    return output.sort
  end

  def self.printSyllables
    separator = ', '
    puts "Initial syllables (#{InitialSyllables.size}):"
    puts self.getSyllableStrings(InitialSyllables).join(separator)
    puts "Extending syllables (#{ExtendingSyllables.size}):"
    puts self.getSyllableStrings(ExtendingSyllables).join(separator)
    puts "Final consonants (#{FinalConsonants.size}):"
    puts FinalConsonants.sort.join(separator)
  end

  LexiconData = self.loadLexicon
  Syllables = LexiconData[0]
  InitialSyllables = Syllables[0]
  ExtendingSyllables = Syllables[1]
  FinalConsonants = Syllables[2]
  Scales = LexiconData[1]
  InitialSyllableScale = Scales[0]
  ExtendingSyllablesScale = Scales[1]
  FinalConsonantsScale = Scales[2]
  Words = LexiconData[2]
end
