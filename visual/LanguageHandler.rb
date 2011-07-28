require 'www-library/BaseHandler'
require 'www-library/HTMLWriter'

class LanguageHandler < WWWLib::BaseHandler
  def renderAddWordForm
    writer = getWriter
    writer.form(@submitWordHandler.getPath) do
      writer.text('Name of the function', FunctionField)
      counter = 0
      options = ArgumentCountDescriptions.map do |description|
        option = WWWLib::SelectOption.new(description, counter.to_s)
        counter += 1
        option
      end
      writer.withLabel('Arguments') do
        writer.select(ArgumentCountField, options)
      end
      options = {
        'Generate pronunciation automatically' => 0,
        'Specify X-SAMPA manually' => 1,
      }.map do |description, value|
        WWWLib::SelectOption.new(description, value.to_s)
      end
      writer.select(GeneratePronunciationField, options)
      writer.text('Specify pronunciation manually', PronunciationField)
      options = {
        'Regular new function entry' => NewFunction,
        'Functional alias' => NewAlias,
      }.map do |description, field|
        WWWLib::SelectOption.new(description, field)
      end
      writer.select(TypeField, options)
      writer.text('Alias', AliasField)
      writer.textArea('Description', DescriptionField) {}
      writer.submit
    end
    return writer.output
  end
end
