require 'www-library/HTMLWriter'

require 'application/BaseHandler'
require 'application/Generator'

class LanguageHandler < BaseHandler
  def mapToOptions(map)
    return map.map do |description, value|
      WWWLib::SelectOption.new(description, value.to_s)
    end
  end

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
      options = mapToOptions(
        'Generate word automatically' => 0,
        'Specify X-SAMPA manually' => 1,
      )
      writer.withLabel('Word generation') do
        writer.select(WordForm::GenerateWord, options)
      end
      options = []
      Generator::Words.size.times do |i|
        options << WWWLib::SelectOption.new("Class #{i + 1}", i.to_s)
      end
      writer.withLabel('Automatic word generation priority class') do
        writer.select(WordForm::Priority, options)
      end
      writer.text('Specify word manually', WordForm::Word)
      options = mapToOptions(
        'Regular new function entry' => NewFunction,
        'Functional alias' => NewAlias,
      )
      writer.withLabel('Type of entry') do
        writer.select(WordForm::Type, options)
      end
      writer.text('Alias', WordForm::Alias)
      writer.textArea('Description', WordForm::Description) {}
      writer.text('Group', WordForm::Group)
      writer.submit
    end
    return writer.output
  end

  def renderSubmissionConfirmation
    writer = getWriter
    writer.p do
      'A new entry has been created.'
    end
  end
end
