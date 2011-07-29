require 'nil/string'

require 'www-library/BaseHandler'
require 'www-library/RequestHandler'
require 'www-library/Forms'

require 'visual/LanguageHandler'

class LanguageHandler < WWWLib::BaseHandler
  class WordForm < WWWLib::Forms
    Function = 'function'
    ArgumentCount = 'argumentCount'
    GenerateWord = 'generateWord'
    Word = 'word'
    Type = 'type'
    Description = 'description'
    Alias = 'alias'
    Group = 'group'
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
    addWordHandler = WWWLib::RequestHandler.handler('addWord', method(:addWord))
    addHandler(addWordHandler)
    @submitWordHandler = WWWLib::RequestHandler.handler('submitWord', method(:submitWord))
    addHandler(@submitWordHandler)
  end

  def addWord(request)
    title = 'Add a new word'
    return @generator.get(renderAddWordForm, request, title)
  end

  def submitWord(request)
    form = WordForm.new(request)
    if form.error
      argumentError
    end
    argumentCount = form.argumentCount.to_i
    generateWord = form.generateWord.to_i == 1
    if ![NewFunction, NewAlias].include?(form.type)
      argumentError
    end
    
  end
end
