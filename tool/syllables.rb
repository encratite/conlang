$:.concat ['.', '..']

require 'application/Generator'

puts Generator::Words[1].sort.inspect
Generator.printSyllables
