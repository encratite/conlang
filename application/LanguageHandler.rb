require 'nil/string'

require 'www-library/BaseHandler'
require 'www-library/RequestHandler'

require 'visual/LanguageHandler'

class LanguageHandler < WWWLib::BaseHandler
  FunctionField = 'function'
  ArgumentCountField = 'argumentCount'
  GeneratePronunciationField = 'generatePronunciation'
  PronunciationField = 'pronunciation'
  TypeField = 'type'
  DescriptionField = 'description'
  AliasField = 'alias'

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
    @submitWordHandler = WWWLib::RequestHandler.handler('submitWord', method(:submitWord))
    addHandler(addWordHandler)
  end

  def addWord(request)
    title = 'Add a new word'
    return @generator.get(renderAddWordForm, request, title)
  end

  def submitWord(request)

  end
end
