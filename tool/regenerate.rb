$:.concat ['.', '..']

require 'application/database'
require 'application/Generator'

require 'configuration/Configuration'

puts "You are about to overwrite the current lexicon. Are you sure you want to continue? Enter 'yes' to confirm."
text = STDIN.gets.strip
if text.downcase != 'yes'
  puts 'Aborting.'
  exit
end

puts 'Regenerating lexicon...'

database = getDatabase(Configuration::Database)
lexicon = database[:lexicon]
usedWords = []
database.transaction do
  beginning = Time.now
  updates = []
  targets = lexicon.all
  targets.each do |row|
    function = row[:function_name]
    oldWord = row[:word]
    priority = Generator.getPriority(oldWord)
    if priority == nil
      priority = oldWord.size >= 4 ? 1 : 0
      puts "Unable to determine the priority of #{function.inspect}, assuming #{priority}"
    end
    newWord = Generator.generateUnusedWord(usedWords, priority)
    if newWord == nil
      if priority == 1
        puts "No space left for #{function.inspect}, aborting"
        exit
      end
      puts "Upgraded priority class for #{function.inspect}"
      newWord = Generator.generateUnusedWord(usedWords, 1)
    end
    row[:word] = newWord
    row[:last_modified] = Time.now.utc
    row.delete(:id)
    updates << row
    usedWords << newWord
  end
  lexicon.truncate
  updates.each do |row|
    lexicon.insert(row)
  end
  duration = Time.now - beginning
  puts "Updated #{targets.size} words in #{duration} s"
end
