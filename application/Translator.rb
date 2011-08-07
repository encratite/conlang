require 'XSAMPA'

class Translator
  class Error < Exception
  end

  class Function
    attr_reader :function, :word, :argumentCount

    def initialize(row)
      @function = row[:function_name]
      @word = row[:word]
      @argumentCount = row[:argument_count]
    end
  end

  class FunctionInstance
    attr_reader :function, :word, :argumentCount

    attr_accessor :arguments

    def initialize(instance)
      @function = instance.function
      @word = instance.word
      @argumentCount = instance.argumentCount
      @arguments = []
    end

    def serialise
      output = @word
      if @arguments.size != @argumentCount
        raise Error.new("Invalid argument count for function \"#{function}\", expected #{@argumentCount}, not #{@arguments.size}")
      end
      if @function == 'voidAll'
        target = @arguments.first
        if !target.arguments.empty?
          raise Error.new("The argument of a #{@function} may have no further arguments")
        end
        output += " #{target.word}"
      else
        @arguments.each do |argument|
          output += " #{argument.serialise}"
        end
      end
      return output
    end

    def inspect
      if @arguments.empty?
        return "#{@function}"
      else
        argumentString = @arguments.map { |x| x.inspect }.join(', ')
        return "#{@function}(#{argumentString})"
      end
    end
  end

  def initialize(lexicon)
    @functions = lexicon.select(:function_name, :word, :argument_count).all.map do |entry|
      Function.new(entry)
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

  def getFunction(functionName)
    @functions.each do |function|
      if function.function == functionName
        return FunctionInstance.new(function)
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
    function = getFunction(functionName)
    if function == nil
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
            input = skipTrim(input)
          else
            functionalComponentData = translateFunctionalComponent(input)
            if functionalComponentData == nil
              parserError('Expected an argument', input)
            end
            input, argument = functionalComponentData
            function.arguments << argument
          end
        end
      else
        #nullary
      end
    end
    return [input, function]
  end

  def translate(input)
    input = input.gsub("\r", '')
    xsampaOutput = ''
    ipaOutput = ''
    skipCharacters = " .,:;-!?\n\r"
    while !input.empty?
      letter = input[0]
      if skipCharacters.include?(letter)
        xsampaOutput += letter
        ipaOutput += letter
        input = skip(input)
        next
      end
      functionalComponentData = translateFunctionalComponent(input)
      if functionalComponentData == nil
        parseError('Expected a function', input)
      end
      input, function = functionalComponentData
      serialised = function.serialise
      xsampaOutput += serialised
      ipaOutput += XSAMPA.toIPA(serialised)
    end
    return xsampaOutput, ipaOutput
  end
end
