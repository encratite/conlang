require 'nil/random'

require 'application/Array'

module Generator
  Vowels = [
    'i',
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
    'ia',
    'iu',
    'ai',
    'au',
    'ui',
    'ua',
  ]

  Nasals = [
    'm',
    'N',
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
    'l',
  ]

  InitialVoicelessFricatives = [
    'h',
  ]

  FinalVoicelessFricatives = [
    'f',
    's',
    'S',
  ]

  VoicedFricatives = [
    'v',
    'z',
    'Z',
  ]

  Taps = [
    '4',
  ]

  Stops = [
    '?',
  ]

  InitialComposites = [
    'tS',
    'ts',

    'dZ',
    'dz',
  ]

  VowelCluster = Vowels + Diphthongs

  Plosives = VoicelessPlosives + VoicedPlosives
  InitialFricatives = InitialVoicelessFricatives
  FinalFricatives = FinalVoicelessFricatives + VoicedFricatives

  InitialConsonants = Plosives + InitialFricatives + Taps + Stops + InitialComposites
  FinalConsonants = Nasals + Approximants + FinalFricatives

  Words = [
    InitialConsonants * VowelCluster,
    InitialConsonants * VowelCluster * FinalConsonants,
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
    while true
      words = Words[priority]
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
    weights = [6, 2, 1]
    Words.size.times do |i|
      scale.add(i, weights[i])
    end
    words.times do |i|
      generatedWords << self.generateWord(scale.get)
    end
    return generatedWords.join(' ')
  end
end
