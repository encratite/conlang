require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  Vowels = [
    'i',
    'u',
    'e',
    'o',
  ]

  FinalVowels = [
    '@',
    'E',
    'O',
  ]

  ExtendingVowels = [
    'a',
  ]

  Nasals = [
    'm',
    'n'
  ]

  FinalNasals = [
    #'N',
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
  ]

  FinalApproximants = [
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
    #'C',
    #'T',
  ]

  VoicedFricatives = [
    #'v',
    #'z',
    #'Z',
    #'G',
    #'j\\',
    #'D',
  ]

  Taps = [
    #'4',
  ]

  Stops = [
    #'?',
  ]

  ConsonantClusters = [
    #'St',
    #'Zd',

    #'st',
    #'zd',
  ]

  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = VoicelessFricatives + VoicedFricatives

  Initials = Nasals + Plosives + Approximants + InitialVoicelessFricatives + Taps + Stops
  Finals = FinalApproximants + VoicelessFricatives + FinalNasals
  Medials = Initials + Taps + ConsonantClusters

  Words = [
    Initials * Vowels,
    Initials * FinalVowels * Finals,
    Initials * ExtendingVowels * Medials * Vowels,
    Initials * ExtendingVowels * Medials * FinalVowels * Finals,
  ].map { |x| x.to_set }

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
    weights = [6, 4, 3, 1]
    Words.size.times do |i|
      scale.add(i, weights[i])
    end
    while true
      priority = scale.get
      syllableCount -= SyllableCounts[priority]
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
