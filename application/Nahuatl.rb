require 'nil/file'

require 'application/Generator'

module Nahuatl
  Replacements = {
    'ch' => 'tS',
    'tl' => 'tK',
    'hu' => 'w',
    'tz' => 'ts',
    'qu' => 'k_w',
    'cu' => 'k_w',
    'c' => 'k',
    'y' => 'j',
    #ignore glottal stops
    #'h' => '?',
    'h' => '',
    'x' => 'S',
    'z' => 's',
    #???
    'u' => 'o',
    'ia' => 'ja',
    'ie' => 'je',
    'io' => 'jo',
  }

  BannedSubstrings = [
    'r',
    'gn',
    'v',
    'f',
    'g',
    'd',
  ]

  def self.getPhonemicSegments(word)
    segments = Generator::Vowels + Generator::Consonants
    output = []
    processedWord = word
    while true
      hit = false
      segments.each do |segment|
        if processedWord.size < segment.size
          next
        end
        if processedWord[0..segment.size - 1] == segment
          output << segment
          hit = true
          processedWord = processedWord[segment.size..-1]
          break
        end
      end
      if !hit
        raise "Unable to load the phonemic segments of the string #{processedWord.inspect} in the word #{word.inspect}"
      end
      break if processedWord.empty?
    end
    #puts "#{word.inspect} => #{output.inspect}"
    return output
  end

  def self.loadLexicon(path = 'data/nahuatl')
    lines = Nil.readLines(path)
    lexicon = []
    lines.each do |line|
      match = line.match(/.+? :: ([a-z]+)/)
      if match == nil
        next
      end
      word = match[1]
      processedWord = word
      Replacements.each do |key, value|
        processedWord = processedWord.gsub(key, value)
      end
      ('a'..'z').each do |letter|
        processedWord = processedWord.gsub(letter + letter, letter)
      end
      banned = false
      BannedSubstrings.each do |target|
        if processedWord.index(target)
          banned = true
          break
        end
      end
      next if banned
      segments = self.getPhonemicSegments(processedWord)
      #puts segments.inspect
      lexicon << segments
    end
    return lexicon
  end

  def self.loadFrequencyData
    consonantVowelFrequencies = {}
    finalConsonantFrequencies = {}
    lexicon = self.loadLexicon()
    lexicon.each do |segment|
      offset = 0
      (segment.size - 1).times do |i|
        consonant = segment[i]
        vowel = segment[i + 1]
        if Generator::Consonants.include?(consonant) && Generator::Vowels.include?(vowel)
          pair = [consonant, vowel]
          if consonantVowelFrequencies[pair]
            consonantVowelFrequencies[pair] += 1
          else
            consonantVowelFrequencies[pair] = 0
          end
        end
        vowel = segment[0]
        if Generator::Vowels.include?(vowel)
          pair = ['?', vowel]
          if consonantVowelFrequencies[pair]
            consonantVowelFrequencies[pair] += 1
          else
            consonantVowelFrequencies[pair] = 0
          end
        end
        consonant = segment[-1]
        if Generator::ExtendingConsonants.include?(consonant)
          if finalConsonantFrequencies[consonant]
            finalConsonantFrequencies[consonant] += 1
          else
            finalConsonantFrequencies[consonant] = 0
          end
        end
      end
    end
    return consonantVowelFrequencies, finalConsonantFrequencies
  end
end
