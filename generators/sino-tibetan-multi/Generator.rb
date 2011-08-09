require 'set'

require 'nil/random'

require 'application/Array'

module Generator
  Vowels = [
    'i',
    #'a_"',
    'a',
    'u',
    #'e_o',
    'e',
    #'o_o',
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
    'n',
  ]

  FinalNasals = [
    'N',
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

  VoicelessFricatives = [
    'f',
    's',
    'S',
    'x',
    'C',
  ]

  VoicedFricatives = [
  ]

  Stops = [
    '?',
  ]

  VoicelessAffricates = [
    'tS',
    'ts',
  ]

  VoicedAffricates = [
    #'dZ',
    #'dz',
  ]

  NasalVowelClusters = [
    'i',
    'a',
    'u',
    'ia',
    'ua',
  ] * FinalNasals

  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = VoicelessFricatives + VoicedFricatives
  Affricates = VoicelessAffricates + VoicedAffricates

  BasicConsonants = Nasals + Plosives + Approximants + Fricatives + Affricates
  ExtendedConsonants = Stops

  Finals = Vowels + Diphthongs + NasalVowelClusters
  BasicSyllable = BasicConsonants * Finals
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
    puts "Consonants: #{BasicConsonants.size + ExtendedConsonants.size + FinalNasals.size}"
    puts "Pure vowels: #{Vowels.size}"
    puts "Diphthongs: #{Diphthongs.size}"
    puts "Basic consonants: #{BasicConsonants.size}"
    puts "Extended consonants: #{ExtendedConsonants.size}"
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
