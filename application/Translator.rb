class Translator
  class Error < Exception
  end

  class Word
    attr_reader :function, :word, :argumentCount

    def initialize(row)
      @function  = row[:function_name]
      @word = row[:word]
      @argumentCount = row[:argument_count]
    end
  end

  def initialize(lexicon)
    @words = lexicon.filter(:function_name, :word, :argument_count).all.map do |entry|
      Word.new(entry)
    end
  end

  def readFunctionName(input)
    pattern = /^[a-zA-z0-9]+/
    match = input.match(pattern)
    if match == nil
      return nil
    end
    name = match[0]
    remainingString = input[name.size..-1]
    return [name, remainingString]
  end

  def getWord(function)
    @words.each do |word|
      if word.function == function
        return word
      end
    end
    return nil
  end

  def error(message)
    raise Error.new(message)
  end

  def translateFunctionalComponent(input)
    functionNameData = readFunctionName(input)
    if functionNameData == nil
      return nil
    end
    functionName, input = functionNameData
    word = getWord(functionName)
    if word == nil
      error "Invalid function name: #{functionName}"
    end
    input = input.trim
    if input.empty?
    end
  end
end
