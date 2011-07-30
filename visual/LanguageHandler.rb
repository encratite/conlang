# -*- coding: utf-8 -*-
require 'www-library/HTMLWriter'

require 'application/BaseHandler'
require 'application/Generator'

require 'nil/time'

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
      writer.text('Rank within group (integer, lower number means higher rank)', WordForm::GroupRank)
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

  def renderWords(request, words)
    privileged = isPrivileged(request)
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
        if privileged
          descriptions << 'Actions'
        end
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
            functionString = "#{function}(#{argumentString})"
          else
            functionString = function
          end
          ipa = XSAMPA.toIPA(word[:word])
          description = word[:description]
          writer.td do
            writer.span(class: 'function', id: function) do
              function
            end
          end
          writer.td do
            writer.span(class: 'ipa') do
              ipa
            end
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
              writer.p(class: 'alias') do
                "Alias: #{aliasDefinition}"
              end
            end
          end
          writer.td do
            word[:group_name]
          end
          writer.td do
            word[:time_added].utcString
          end
          if privileged
            writer.td do
              actions = {
                'Delete' => @deleteWordHandler,
              }
              first = true
              id = word[:id].to_s
              actions.each do |description, handler|
                if first
                  first = false
                else
                  writer.write ', '
                end
                writer.a(href: handler.getPath(id)) do
                  description
                end
              end
              nil
            end
          end
        end
      end
    end
    return writer.output
  end

  def renderDeletionConfirmation
    writer = getWriter
    writer.p do
      'The word has been deleted.'
    end
    return writer.output
  end
end
