$:.concat ['.', '..']

require 'application/Generator'

require 'XSAMPA'

count = 7
lines = 4
useIPA = false

if ARGV.size > 0
  words = []
  count.times do
    words << Generator.generateWord(priority)
  end

  output = words.join(' ')
else
  output = []
  lines.times do
    output << Generator.noise(count)
  end
  output = output.join("\n")
end
if useIPA
  output = XSAMPA.toIPA(output)
end
puts output
