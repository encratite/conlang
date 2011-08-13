require 'set'

require 'nil/random'

require 'application/Array'
require 'application/Nahuatl'

module Generator
  Vowels = [
    'a',
    'i',
    'u',
    'e',
    'o',
  ]

  InitialConsonants = [
    'p',
    't',
    'k',

    'g',
    'b',
    'd',

    'j',
    'w',

    'h',

    '?',
  ]

  ExtendingConsonants = [
    'm',
    'n',

    'l',

    'f',
    's',
    'S',

    'tS',
    'ts',
  ]

  Consonants = ExtendingConsonants + InitialConsonants

  Initials = InitialConsonants * Vowels - ['ji', 'wu']

  Words = [
    Initials,
    Initials * ExtendingConsonants,
    Initials * ExtendingConsonants * Vowels,
    Initials * ExtendingConsonants * Vowels * ExtendingConsonants,
  ]
  SyllableCounts = [
    1,
    1,
    2,
    2,
  ]

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
    wordClass = Words[priority]
    return wordClass[rand(wordClass.size)]
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

  def self.getSyllableStrings(input)
    output = input.map do |consonant, vowel|
      consonant + vowel
    end
    return output.sort
  end
end
