# -*- coding: utf-8 -*-
require 'nil/string'

require 'www-library/FormFields'
require 'www-library/HTTPReply'
require 'www-library/RequestHandler'

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
    WWWLib::RequestHandler.newBufferedObjectsGroup

    addWordHandler = WWWLib::RequestHandler.menu('Add a new [wəːd]', 'addWord', method(:addWord), nil, method(:isPrivileged))
    @submitWordHandler = WWWLib::RequestHandler.handler('submitWord', method(:submitWord))
    @viewWordsHandler = WWWLib::RequestHandler.menu('View [ˈlɛksɪkən]', 'viewWords', method(:viewWords))
    @deleteWordHandler = WWWLib::RequestHandler.handler('deleteWord', method(:deleteWord), 1)
    @regenerateWordHandler = WWWLib::RequestHandler.handler('regenerateWord', method(:regenerateWord), 1)
    @viewGroupHandler = WWWLib::RequestHandler.handler('viewGroup', method(:viewGroup), 1)

    WWWLib::RequestHandler.getBufferedObjects.each do |handler|
      addHandler(handler)
    end
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

  def generateWord(priority)
    usedWords = lexicon.select(:word).all.map { |x| x[0] }
    unusedWords = Generator::Words[priority].reject do |word|
      usedWords.include?(word)
    end
    if unusedWords.empty?
      return nil
    end
    word = unusedWords[rand(unusedWords.size)]
    return word
  end

  def processWordSubmission(request)
    form = WordForm.new(request)
    if form.error
      argumentError
    end
    argumentCount = form.argumentCount.to_i
    doGenerateWord = form.generateWord.to_i == 1
    if ![NewFunction, NewAlias].include?(form.type)
      argumentError
    end
    priority = form.priority.to_i
    if priority < 0 || priority >= Generator::Words.size
      argumentError
    end
    @database.transaction do
      type = form.type.to_sym
      if lexicon.where(function_name: form.function).count > 0
        submissionError 'This function name is already taken.'
      end
      if doGenerateWord
        word = generateWord(priority)
        if word == nil
          submissionError 'There are no unused words left for the specified priority class.'
        end
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
      if form.type.to_sym == :newAlias
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
  end

  def submitWord(request)
    privilegeCheck(request)
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
    privilegeCheck(request)
    id = request.arguments.first.to_i
    begin
      lexicon.where(id: id).delete
    rescue Sequel::Error
      argumentError
    end
    title = 'Word deleted'
    return @generator.get(renderDeletionConfirmation, request, title)
  end

  def getPriority(word)
    priority = 0
    Generator::Words.each do |wordClass|
      if wordClass.include?(word)
        return priority
      end
      priority += 1
    end
    return nil
  end

  def regenerateWord(request)
    privilegeCheck(request)
    id = request.arguments.first.to_i
    function = nil
    @database.transaction do
      result = lexicon.where(id: id).all
      if result.empty?
        argumentError
      end
      row = result.first
      function = row[:function_name]
      priority = getPriority(row[:word])
      if priority == nil
        plainError 'Unable to find the word in the lexicon.'
      end
      newWord = generateWord(priority)
      if newWord == nil
        plainError 'No space left in this priority class.'
      end
      lexicon.where(id: id).update(word: newWord)
    end
    path = "#{request.referrer}##{function}"
    return WWWLib::HTTPReply.refer(path)
  end

  def viewGroup(request)
    group = request.arguments.first
    if group.empty?
      argumentError
    end
    words = lexicon.where(group_name: group).order_by(:group_rank).all
    if words.empty?
      argumentError
    end
    title = "Group \"#{group}\""
    output = renderWords(request, words)
    return @generator.get(output, request, title)
  end
end
