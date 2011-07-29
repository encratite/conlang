require 'www-library/BaseHandler'
require 'www-library/HTMLWriter'

class LanguageHandler < WWWLib::BaseHandler
  def renderAddWordForm
    writer = getWriter
    writer.form(@submitWordHandler.getPath) do
      writer.text('Name of the function', WordForm::Function)
      counter = 0
      options = ArgumentCountDescriptions.map do |description|
        option = WWWLib::SelectOption.new(description, counter.to_s)
        counter += 1
        option
      end
      writer.withLabel('Argument count for this function') do
        writer.select(WordForm::ArgumentCount, options)
      end
      options = {
        'Generate word automatically' => 0,
        'Specify X-SAMPA manually' => 1,
      }.map do |description, value|
        WWWLib::SelectOption.new(description, value.to_s)
      end
      writer.withLabel('Word generation') do
        writer.select(WordForm::GenerateWord, options)
      end
      writer.text('Specify word manually', WordForm::Word)
      options = {
        'Regular new function entry' => NewFunction,
        'Functional alias' => NewAlias,
      }.map do |description, field|
        WWWLib::SelectOption.new(description, field)
      end
      writer.withLabel('Type of entry') do
        writer.select(WordForm::Type, options)
      end
      writer.text('Alias', WordForm::Alias)
      writer.textArea('Description', WordForm::Description) {}
      writer.submit
    end
    return writer.output
  end
end
