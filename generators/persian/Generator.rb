require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  FrontVowels = [
    'i',
    'e',
    '{',
  ]

  BackVowels = [
    'u',
    'o',
    'Q',
  ]

  Nasals = [
    'm',
    'n',
  ]

  VoicelessPlosives = [
    'k',
    'p',
    't',
  ]

  VoicedPlosives = [
    'g',
    'b',
    'd',
  ]

  Approximants = [
    #'j',
    #'w',
    'l',
  ]

  InitialVoicelessFricatives = [
    'h',
  ]

  VoicelessFricatives = [
    'f',
    's',
    'S',
    'x',
  ]

  VoicedFricatives = [
    'v',
    'z',
    'Z',
    'G',
  ]

  Stops = [
    '?',
  ]

  Taps = [
    '4',
  ]

  VoicelessAffricates = [
    'tS',
    #'ts',
  ]

  VoicedAffricates = [
    'dZ',
    #'dz',
  ]

  Vowels = FrontVowels + BackVowels
  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = VoicelessFricatives + VoicedFricatives
  Affricates = VoicelessAffricates + VoicedAffricates

  Initials = Nasals + Plosives + Approximants + InitialVoicelessFricatives + Stops + Taps + Affricates
  Medials = ['z', 'Z'] * VoicedPlosives + ['s', 'S'] * VoicelessPlosives

 Words = [
    Initials * Vowels,
    Initials * Vowels * VoicelessFricatives,
    Initials * FrontVowels * Medials * FrontVowels + Initials * BackVowels * Medials * BackVowels,
  ].map { |x| x.to_set }

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
    while true
      words = Words[priority].to_a
      word = words[rand(words.size)]
      return word
    end
  end

  def self.describe
    self.printClassSizes
    self.printWordCount
  end

  def self.noise(syllableCount)
    generatedWords = []
    scale = Nil::RandomScale.new
    weights = [4, 2, 1]
    Words.size.times do |i|
      scale.add(i, weights[i])
    end
    while true
      priority = scale.get
      syllableCount -= priority + 1
      generatedWords << self.generateWord(priority)
      if syllableCount <= 1
        break
      end
    end
    if syllableCount == 1
      generatedWords << self.generateWord(0)
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
    unusedWords = Generator::Words[priority].reject do |word|
      usedWords.include?(word)
    end
    if unusedWords.empty?
      return nil
    end
    word = unusedWords[rand(unusedWords.size)]
    return word
  end
end
