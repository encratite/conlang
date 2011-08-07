require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  Vowels = [
    'i',
    'a_"',
    'u',
    'o_o',
    'e_o',
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
    'j',
    'w',
    'l',
  ]

  VoicelessFricatives = [
    'h',
    'f',
    's',
    'S',
  ]

  VoicedFricatives = [
    #'v',
    #'z',
    #'Z',
  ]

  Stops = [
    '?',
  ]

  Taps = [
    '4',
  ]

  VoicelessAffricates = [
    'tS',
    'ts',
  ]

  VoicedAffricates = [
    #'dZ',
    #'dz',
  ]

  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = VoicelessFricatives + VoicedFricatives
  Affricates = VoicelessAffricates + VoicedAffricates

  BasicConsonants = Nasals + Plosives + Approximants + VoicelessFricatives
  ExtendedConsonants = Affricates + Stops + Taps

  BasicSyllable = BasicConsonants * Vowels
  ExtendedSyllable = ExtendedConsonants * Vowels

  Words = [
    BasicSyllable,
    ExtendedSyllable * BasicSyllable,
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
    puts "Consonants: #{BasicConsonants.size + ExtendedConsonants.size}"
    puts "Vowels: #{Vowels.size}"
    self.printClassSizes
    self.printWordCount
  end

  def self.noise(syllableCount)
    generatedWords = []
    scale = Nil::RandomScale.new
    weights = [2, 1]
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
