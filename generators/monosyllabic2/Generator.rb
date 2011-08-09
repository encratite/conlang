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

  Diphthongs = [
    'ia',
    'iu',
    'ai',
    'au',
    'ui',
    'ua',

    'iE',
    'iO',
    'Ei',
    'Oi',
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

  UnclusteredVoicelessFricatives = [
    'h',
  ]

  VoicelessFricatives = [
    'f',
    's',
    'S',
    'x',
    'X',
    'T',
    'C',
  ]

  VoicedFricatives = [
    'v',
    'z',
    'Z',
    'G',
    'R',
    'D',
    'j\\',
  ]

  Stops = [
    '?',
  ]

  Taps = [
    '4',
  ]

  Plosives = VoicelessPlosives + VoicedPlosives
  Fricatives = VoicelessFricatives + VoicedFricatives

  PlosiveFricativeClusters = VoicelessPlosives * ['s', 'S'] + VoicedPlosives * ['z', 'Z']
  FricativePlosiveClusters = ['s', 'S'] * VoicelessPlosives + ['z', 'Z'] * VoicedPlosives
  #FricativeNasalClusters = VoicelessFricatives * ['n'] + VoicedFricatives * ['m']
  FricativeNasalClusters = ['s', 'S', 'z', 'Z'] * Nasals
  PlosiveNasalClusters = ['kn', 'pn', 'tm']
  PlosiveElClusters = ['kl', 'pl', 'tK', 'gl', 'bl', 'dK\\']
  FricativeClusters = ['sf', 'Sf', 'zv', 'Zv']

  ConsonantClusters =
    PlosiveFricativeClusters +
    FricativePlosiveClusters +
    Plosives * ['4'] +
    PlosiveNasalClusters +
    PlosiveElClusters +
    FricativeNasalClusters +
    VoicelessFricatives * ['l'] +
    FricativeClusters +
    []

  VowelClusters = Vowels + Diphthongs

  def self.generateFinalClusters
    output = VowelClusters
    VowelClusters.each do |vowelCluster|
      if vowelCluster[-1] == 'a'
        output += [vowelCluster] * FinalNasals
      end
    end
    return output
  end

  Consonants = Nasals + Plosives + Approximants + UnclusteredVoicelessFricatives + Fricatives + Stops + Taps
  FinalCluster = self.generateFinalClusters

  Words = [
    Consonants * FinalCluster,
    ConsonantClusters * FinalCluster,
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
    puts "Consonants: #{Consonants.size}"
    puts "Consonant clusters: #{ConsonantClusters.size}"
    puts "Vowels: #{Vowels.size}"
    puts "Diphthongs: #{Diphthongs.size}"
    self.printClassSizes
    self.printWordCount
  end

  def self.noise(syllableCount)
    generatedWords = []
    scale = Nil::RandomScale.new
    weights = [3, 1]
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
