$:.concat ['.', '..']

require 'application/database'
require 'application/Translator'

require 'configuration/Configuration'

input = ARGV.first

database = getDatabase(Configuration::Database)
translator = Translator.new(database[:lexicon])
output = translator.translateFunctionalComponent(input)

puts output.inspect
