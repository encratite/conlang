require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  Vowels = [
    'i',
    'a',
    'u',
    'e',
    'E',
    'o',
    'O',
    '@',
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
    'w',
  ]

  FinalApproximants = [
    'j',
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
    'T',
    'C',
  ]

  VoicedFricatives = [
    'v',
    'z',
    'Z',
    'G',
    'D',
    'j\\',
  ]

  Stops = [
    '?',
  ]

  Taps = [
    '4',
  ]

  VoicelessAffricates = [
    #'tS',
    #'ts',
  ]

  VoicedAffricates = [
    #'dZ',
    #'dz',
  ]

  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = InitialVoicelessFricatives + VoicelessFricatives + VoicedFricatives
  Affricates = VoicelessAffricates + VoicedAffricates

  Initials = Approximants + Fricatives + Stops + Taps
  Medials = Vowels
  Finals = Nasals + FinalApproximants + VoicedPlosives

  Words = [
    Initials * Medials,
    Initials * Medials * Finals,
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
    puts "Initials: #{Initials.size}"
    puts "Medials: #{Medials.size}"
    puts "Finals: #{Finals.size}"
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
    syllableCount.times do
      priority = scale.get
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
