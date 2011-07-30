require 'nil/string'

require 'www-library/RequestHandler'
require 'www-library/FormFields'

require 'application/BaseHandler'
require 'application/Generator'

require 'visual/LanguageHandler'

class LanguageHandler < BaseHandler
  class WordForm < WWWLib::FormFields
    Function = 'function'
    ArgumentCount = 'argumentCount'
    GenerateWord = 'generateWord'
    Priority = 'priority'
    Word = 'word'
    Type = 'type'
    Description = 'description'
    Alias = 'alias'
    Group = 'group'
    GroupRank = 'rank'
  end

  class SubmissionError < Exception
  end

  NewFunction = 'newFunction'
  NewAlias = 'newAlias'

  ArgumentCountDescriptions = [
    'Nullary',
    'Unary',
    'Binary',
    'Ternary',
  ]

  def installHandlers
    addWordHandler = WWWLib::RequestHandler.menu('Add a new word', 'addWord', method(:addWord), nil, method(:isPrivileged))
    addHandler(addWordHandler)
    @submitWordHandler = WWWLib::RequestHandler.handler('submitWord', method(:submitWord))
    addHandler(@submitWordHandler)
    viewWordsHandler = WWWLib::RequestHandler.menu('View lexicon', 'viewWords', method(:viewWords))
    addHandler(viewWordsHandler)
    @deleteWordHandler = WWWLib::RequestHandler.handler('deleteWord', method(:deleteWord), 1)
    addHandler(@deleteWordHandler)
  end

  def lexicon
    return @database[:lexicon]
  end

  def addWord(request)
    title = 'Add a new word'
    return @generator.get(renderAddWordForm, request, title)
  end

  def submissionError(text)
    raise SubmissionError.new(text)
  end

  def wordIsUsed(word)
    return lexicon.where(word: word).count > 0
  end

  def processWordSubmission(request)
    form = WordForm.new(request)
    if form.error
      argumentError
    end
    argumentCount = form.argumentCount.to_i
    generateWord = form.generateWord.to_i == 1
    if ![NewFunction, NewAlias].include?(form.type)
      argumentError
    end
    priority = form.priority.to_i
    if priority < 0 || priority >= Generator::Words.size
      argumentError
    end
    type = form.type.to_sym
    if lexicon.where(function_name: form.function).count > 0
      submissionError 'This function name is already taken.'
    end
    if generateWord
      usedWords = lexicon.select(:word).all.map { |x| x[0] }
      unusedWords = Generator::Words[priority].reject do |word|
        usedWords.include?(word)
      end
      if unusedWords.empty?
        submissionError 'There are no unused words left for the specified priority class.'
      end
      word = unusedWords[rand(unusedWords.size)]
    else
      word = form.word
      if wordIsUsed(word)
        submissionError 'The word you have specified is already taken.'
      end
    end
    if word.empty?
      submissionError 'You have not specified a word.'
    end
    if form.function.empty?
      submissionError 'You have not specified a function name.'
    end
    aliasDefinition = nil
    if form.type == :newAlias
      aliasDefinition = form.alias
    end
    rank = form.groupRank
    if rank.empty?
      rank = nil
    else
      rank = rank.to_i
    end
    data = {
      function_name: form.function,
      argument_count: argumentCount,
      word: word,
      description: form.description,
      alias_definition: aliasDefinition,
      group_name: form.group,
      group_rank: rank,
      time_added: Time.now.utc,
    }
    lexicon.insert(data)
  end

  def submitWord(request)
    if !isPrivileged(request)
      permissionError
    end
    title = nil
    output = nil
    begin
      processWordSubmission(request)
      title = 'New word added'
      output = renderSubmissionConfirmation
    rescue SubmissionError => error
      title = 'Submission error'
      output = renderSubmissionError(error.message)
    end
    return @generator.get(output, request, title)
  end

  def viewWords(request)
    words = lexicon.order(:function_name).all
    title = 'Lexicon'
    output = renderWords(request, words)
    return @generator.get(output, request, title)
  end

  def deleteWord(request)
    if !isPrivileged(request)
      permissionError
    end
    id = request.arguments.first.to_i
    begin
      lexicon.where(id: id).delete
    rescue
      argumentError
    end
    title = 'Word deleted'
    return @generator.get(renderDeletionConfirmation, request, title)
  end
end
