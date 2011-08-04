require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  PalatalisableVowels = [
    'a',
    'u',
    'o',
    'e',
  ]

  Vowels = [
    'i',
  ] + PalatalisableVowels

  BasicNasals = [
    'm',
    #'N',
    'n',
  ]

  ExtendedNasals = [
    'J',
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

  VoicelessPalatalisedPlosives = [
    'k_j',
    'p_j',
    #'t_j',
  ]

  VoicedPalatalisedPlosives = [
    'g_j',
    'b_j',
    #'d_j',
  ]

  Approximants = [
    'j',
    'w',
    'l',
  ]

  VoicelessFricatives = [
    'h',
    #'f',
    's',
    'S',
    #'S\\'
  ]

  VoicedFricatives = [
    #'v',
    #'z',
    #'Z',
  ]

  Taps = [
    '4',
  ]

  Affricates = [
    'tS',
    #'dZ',
    'ts',
    #'dz',
    #'tS\\',
  ]

  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = VoicelessFricatives + VoicedFricatives

  Consonants = BasicNasals + Plosives + Approximants + Fricatives + Taps

  PalatalisedPlosives = VoicelessPalatalisedPlosives + VoicedPalatalisedPlosives
  PalatalisedConsonants = PalatalisedPlosives + ExtendedNasals

  Words = [
    Consonants * Vowels,
    (PalatalisedConsonants * PalatalisableVowels + Affricates * Vowels) * Consonants * Vowels,
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
end
