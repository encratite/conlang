# -*- coding: utf-8 -*-
require 'www-library/HTMLWriter'

require 'application/BaseHandler'
require 'application/Generator'

require 'XSAMPA'

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
        'Generate word automatically' => 1,
        'Specify X-SAMPA manually' => 0,
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
    return writer.output
  end

  def renderSubmissionError(message)
    writer = getWriter
    writer.p do
      message
    end
    return writer.output
  end

  def renderWords(words)
    writer = getWriter
    writer.table(class: 'lexicon') do
      writer.tr do
        descriptions = [
          'Function',
          'IPA',
          'Description',
          'Group',
          'Time added',
        ]
        descriptions.each do |description|
          writer.th do
            description
          end
        end
      end
      argumentLetters = 'αβγδε'
      words.each do |word|
        writer.tr do
          function = word[:function_name]
          argumentCount = word[:argument_count]
          if argumentCount > 0
            argumentLetters = []
            argumentCount.size.times do |i|
              argumentLetters << argumentLetters[i]
            end
            argumentString = argumentLetters.join(', ')
            function = "#{function}(#{argumentString})"
          end
          ipa = XSAMPA.toIPA(word[:word])
          columns = [
            function,
            ipa,
            word[:description]
          ]
          writer.td do
            writer.span(class: 'function') do
              function
            end
          end
          writer.td do
            ipa
          end
          writer.td do
            writer.p do
              if description == nil
                writer.i { 'No description.' }
              else
                description
              end
            end
            aliasDefinition = word[:alias_definition]
            if aliasDefinition != nil
              writer.p do
                "Alias: #{aliasDefinition}"
              end
            end
          end
          writer.td do
            word[:group_name]
          end
          writer.td do
            word[:time_added].to_s
          end
        end
      end
    end
    return writer.output
  end
end
