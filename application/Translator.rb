class Translator
  class Error < Exception
  end

  class Word
    attr_reader :function, :word, :argumentCount

    attr_accessor :arguments

    def initialize(row)
      @function  = row[:function_name]
      @word = row[:word]
      @argumentCount = row[:argument_count]
      @arguments = []
    end
  end

  def initialize(lexicon)
    @words = lexicon.select(:function_name, :word, :argument_count).all.map do |entry|
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

  def parserError(message, input)
    error "#{message}: #{input[0..20].inspect}"
  end

  def skip(input)
    return input[1..-1]
  end

  def skipTrim(input)
    return skip(input).strip
  end

  def translateFunctionalComponent(input)
    functionNameData = readFunctionName(input.strip)
    if functionNameData == nil
      return nil
    end
    functionName, input = functionNameData
    word = getWord(functionName)
    if word == nil
      error "Invalid function name: #{functionName}"
    end
    if input.empty?
      #end of string, no arguments were specified
    else
      #check if it's a nullary invocation
      if input[0] == '('
        #not nullary
        input = skipTrim(input)
        while true
          if input.empty?
            parserError('Unterminated parenthesis', input)
          end
          letter = input[0]
          case letter
          when')'
            #end of the invocation
            #do not trim, otherwise we might modify outer whitespace which is supposed to remain as it is
            input = skip(input)
            break
          when ','
            #argument separator
          else
            functionalComponentData = translateFunctionalComponent(input)
            if functionalComponentData == nil
              parseError('Expected an argument', input)
            end
            input, argumentWord = functionalComponentData
            word.arguments << argumentWord
          end
        end
      else
        #nullary
      end
    end
    return [input, word]
  end
end
