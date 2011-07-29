$:.concat ['.', '..']

require 'application/Generator'

count = 10

if ARGV.size == 1
  priority = ARGV.first.to_i

  words = []
  count.times do
    words << Generator.generateWord(priority)
  end

  puts words.join(' ')
else
  puts Generator.noise(count)
end
