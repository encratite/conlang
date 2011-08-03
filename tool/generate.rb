$:.concat ['.', '..']

require 'application/Generator'

count = 7
lines = 4

if ARGV.size == 1
  priority = ARGV.first.to_i

  words = []
  count.times do
    words << Generator.generateWord(priority)
  end

  puts words.join(' ')
else
  lines.times do
    puts Generator.noise(count)
  end
end
