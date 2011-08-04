require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  Vowels = [
    'i',
    #'a_"',
    'a',
    'u',
    'E',
    'e',
    'O',
    'o',
    '@',
    'y',
  ]

  Diphthongs = [
    #'ia',
    #'iu',
    'ai',
    'au',
    #'ui',
    #'ua',
  ]

  InitialNasals = [
    'm',
  ]

  FinalNasals = [
    'N',
    'n',
  ]

  VoicelessPlosives = [
    'k',
    'p',
    't',
    #Bad contrast with k
    #'q',
  ]

  VoicedPlosives = [
    'g',
    'b',
    'd',
    #Bad contrast with g
    #'G\\',
  ]

  Approximants = [
    'l',
  ]

  InitialVoicelessFricatives = [
    'h',
    #'K',
  ]

  FinalVoicelessFricatives = [
    'f',
    's',
    'S',
    #Bad contrast with h
    #'x',
    #Bad contrast with f
    #'F',
    #Bad contrast with x
    #'X',
    #Bad contrast with s\
    #'s`',
    #Bad contrast with s`
    #'s\\'
  ]

  VoicedFricatives = [
    'v',
    'z',
    'Z',
    #Bad contrast with g
    #'G',
    #Bad contrast with v
    #'B',
    #Bad contrast with z\
    #'z`',
    #Bad contrast with z`
    #'z\\',
  ]

  Taps = [
    '4',
  ]

  Stops = [
    '?',
  ]

  Affricates = [
    'ts',
    'dz',
    'tS',
    'dZ',
    #'t`s`',
    #'d`z`',
    #'ts\\',
    #'dz\\',
  ]

  VowelCluster = Vowels + Diphthongs

  Plosives = VoicelessPlosives + VoicedPlosives
  PalatalisedPlosives = Plosives * ['_j']
  LabialisedPlosives = Plosives * ['_w']
  Fricatives = InitialVoicelessFricatives + FinalVoicelessFricatives + VoicedFricatives

  InitialConsonants = InitialNasals + Plosives + PalatalisedPlosives + LabialisedPlosives + Approximants + Fricatives + Taps + Stops + Affricates
  FinalConsonants = FinalNasals

  Words = [
    InitialConsonants * VowelCluster,
    InitialConsonants * Vowels * FinalConsonants,
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
    puts InitialConsonants.size
    puts VowelCluster.size
    puts FinalConsonants.size
    self.printClassSizes
    self.printWordCount
  end

  def self.noise(words = 8)
    generatedWords = []
    scale = Nil::RandomScale.new
    weights = [3, 1]
    Words.size.times do |i|
      scale.add(i, weights[i])
    end
    words.times do |i|
      generatedWords << self.generateWord(scale.get)
    end
    return generatedWords.join(' ')
  end
end
