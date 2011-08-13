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
    consonantVowelFrequencies, finalConsonantFrequencies = Nahuatl.loadFrequencyData
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
      initialSyllables << string
    end
    extendingSyllables = []
    extendingSyllablesScale = Nil::RandomScale.new
    extendingConsonantFrequencies.each do |segments, frequency|
      consonant, vowel = segments
      string = consonant + vowel
      extendingSyllablesScale.add(string, frequency)
      extendingSyllables << string
    end
    finalConsonants = []
    finalConsonantsScale = Nil::RandomScale.new
    finalConsonantFrequencies.each do |consonant, frequency|
      finalConsonantsScale.add(consonant, frequency)
      finalConsonants << consonant
    end
    #puts initialSyllables.inspect
    #puts extendingSyllables.inspect
    #puts finalConsonants.inspect
    words = [
      initialSyllables * Neutral,
      initialSyllables * finalConsonants,
      initialSyllables * extendingSyllables,
      initialSyllables * extendingSyllables * finalConsonants,
    ]
    return [initialSyllablesScale, extendingSyllablesScale, finalConsonantsScale], words
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
      next if usedWords.include?(word)
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

  Lexicon = self.loadLexicon
  Scales = Lexicon[0]
  InitialSyllableScale = Scales[0]
  ExtendingSyllablesScale = Scales[1]
  FinalConsonantsScale = Scales[2]
  Words = Lexicon[1]
end
