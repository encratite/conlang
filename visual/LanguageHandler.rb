# -*- coding: utf-8 -*-
require 'nil/time'

require 'XSAMPA'

require 'www-library/HTMLWriter'

require 'application/BaseHandler'
require 'application/Generator'
require 'application/Romanisation'
require 'application/TranslationForm'
require 'application/WordForm'
require 'application/XSAMPAAdjustment'

class LanguageHandler < BaseHandler
  ArgumentLetters = {
    'α' => 'alpha',
    'β' => 'beta',
    'γ' => 'gamma',
    'δ' => 'delta',
    'ε' => 'epsilon',
  }

  def mapToOptions(map)
    return map.map do |description, value|
      selected = false
      if value.class == Array
        value, selected = value
      end
      WWWLib::SelectOption.new(description, value.to_s, selected)
    end
  end

  def renderWordForm(submissionHandler, wordFormContents = nil)
    writer = getWriter
    writer.form(submissionHandler.getPath) do
      writer.text('Name of the function', WordForm::Function, wordFormContents == nil ? nil : wordFormContents.function)
      counter = 0
      options = ArgumentCountDescriptions.map do |description|
        option = WWWLib::SelectOption.new(description, counter.to_s)
        if wordFormContents != nil && counter == wordFormContents.argumentCount
          option.selected = true
        end
        counter += 1
        option
      end
      writer.withLabel('Argument count for this function') do
        writer.select(WordForm::ArgumentCount, options)
      end
      options = mapToOptions(
        'Generate word automatically' => 1,
        'Specify X-SAMPA manually' => [0, wordFormContents != nil],
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
      writer.text('Specify word manually', WordForm::Word, wordFormContents == nil ? nil : wordFormContents.word)
      options = mapToOptions(
        'Regular new function entry' => NewFunction,
        'Functional alias' => NewAlias,
      )
      if wordFormContents != nil
        isAlias = wordFormContents.aliasDefinition != nil
        options[0].selected = !isAlias
        options[1].selected = isAlias
      end
      writer.withLabel('Type of entry') do
        writer.select(WordForm::Type, options)
      end
      writer.text('Alias', WordForm::Alias, wordFormContents == nil ? nil : wordFormContents.aliasDefinition)
      writer.textArea('Description', WordForm::Description,  wordFormContents == nil ? nil : wordFormContents.description)
      writer.text('Group', WordForm::Group, wordFormContents == nil ? nil : wordFormContents.group)
      writer.text('Rank within group (integer, lower number means higher rank)', WordForm::GroupRank, wordFormContents == nil ? nil : wordFormContents.rank)
      writer.hidden(WordForm::Id, wordFormContents == nil ? nil : wordFormContents.id)
      writer.submit
    end
    return writer.output
  end

  def renderSubmissionConfirmation(editing = false)
    if editing
      title = 'Word edited'
    else
      title = 'New word added'
    end
    writer = getWriter
    writer.p do
      if editing
        'The word has been updated.'
      else
        'A new entry has been created.'
      end
    end
    return [title, writer.output]
  end

  def renderSubmissionError(message)
    title = 'Submission error'
    writer = getWriter
    writer.p(class: 'error') do
      message
    end
    return [title, writer.output]
  end

  def replaceArgumentLetters(input)
    output = input
    ArgumentLetters.each do |letter, name|
      output = output.gsub(name, letter)
    end
    return output
  end

  def renderWords(request, words)
    privileged = isPrivileged(request)
    writer = getWriter
    writer.p do
      "Number of functions in the database: #{lexicon.count}"
    end
    writer.table(class: 'lexicon') do
      writer.tr do
        descriptions = [
          'Function',
          'Romanisation',
          'IPA',
          #'X-SAMPA',
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
      words.each do |word|
        writer.tr do
          function = word[:function_name]
          argumentCount = word[:argument_count]
          if argumentCount > 0
            usedLetters = []
            argumentLetters = ArgumentLetters.keys
            argumentCount.times do |i|
              usedLetters << argumentLetters[i]
            end
            argumentString = usedLetters.join(', ')
            functionString = "#{function}(#{argumentString})"
          else
            functionString = function
          end
          description = word[:description]
          writer.td do
            writer.span(class: 'function', id: function) do
              functionString
            end
          end
          xsampa = word[:word]
          writer.td do
            romanisation = Romanisation.romaniseXSAMPA(xsampa)
            priority = Generator.getPriority(xsampa)
            if priority == nil
              priorityClass = 'unknownPriority'
            else
              priorityClass = "priority#{priority}"
            end
            writer.span(class: priorityClass) do
              romanisation
            end
          end
          writer.td do
            ipa = XSAMPA.toIPA(XSAMPAAdjustment.adjust(xsampa))
            writer.span(class: 'ipa') do
              ipa
            end
          end
          #writer.td do
          #  writer.span(class: 'xsampa') do
          #    xsampa
          #  end
          #end
          writer.td do
            if description.empty?
              writer.p do
                writer.i { 'No description.' }
              end
            else
              tokens = description.gsub("\r", '').split("\n\n")
              if tokens.size == 2
                description = tokens[0]
                examples = tokens[1].split("\n")
                writer.p do
                  replaceArgumentLetters(description)
                end
                examples.each do |example|
                  writer.p(class: 'examples') { 'Examples:' }
                  writer.p do
                    tokens = example.split(': ')
                    if tokens.size != 2
                      writer.b do
                        'Invalid example.'
                      end
                    else
                      gloss = tokens[0]
                      translation = tokens[1]
                      writer.span(class: 'function', newlineType: nil) { gloss }
                      writer.write ": #{translation}"
                    end
                  end
                end
              else
                writer.p do
                  replaceArgumentLetters(description)
                end
              end
            end
            aliasDefinition = word[:alias_definition]
            if aliasDefinition != nil
              writer.p(class: 'alias') do
                writer.b do
                  'Alias for:'
                end
                writer.write ' '
                writer.span(class: 'function') do
                  replaceArgumentLetters(aliasDefinition)
                end
              end
            end
          end
          writer.td do
            group = word[:group_name]
            if group.empty?
              writer.i { 'No group' }
            else
              writer.a(href: @viewGroupHandler.getPath(group)) do
                group
              end
              rank = word[:group_rank]
              if rank != nil
                writer.write " (#{rank})"
              end
            end
          end
          writer.td do
            word[:time_added].utcString
          end
          if privileged
            writer.td do
              actions = {
                'Edit' => [@editWordHandler, false],
                'Regenerate' => [@regenerateWordHandler, true],
                'Delete' => [@deleteWordHandler, false],
              }
              first = true
              id = word[:id].to_s
              actions.each do |description, handlerData|
                if first
                  first = false
                else
                  writer.write ', '
                end
                handler, anchor = handlerData
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

  def renderTranslationForm
    title = 'Translate'
    writer = getWriter
    writer.p(class: 'translationDescription') do
      'The translation service currently only supports the translation of the functional representations to the language in its IPA representation.'
    end
    writer.form(@submitTranslationHandler.getPath) do
      writer.textArea('Input', TranslationForm::Input)
      writer.submit
    end
    return title, writer.output
  end

  def renderTranslation(xsampaTranslation, ipaTranslation)
    title = 'Translation'
    writer = getWriter
    xsampaTranslation = XSAMPAAdjustment.adjust(xsampaTranslation)
    romanisedTranslation = Romanisation.romaniseXSAMPA(xsampaTranslation)
    targets = {
      'Romanised' => [romanisedTranslation, nil],
      'IPA' => [ipaTranslation, 'ipa'],
      #'X-SAMPA' => [xsampaTranslation, 'xsampa'],
    }
    targets.each do |description, translationData|
      translation, spanClass = translationData
      writer.p(class: 'translationOutputDescription') do
        "#{description}:"
      end
      writer.ul(class: 'translation') do
        lines = translation.split("\n")
        lines.each do |line|
          if line.empty?
            line = '&nbsp;'
          else
            if spanClass == nil
              line = line[0].upcase + line[1..-1]
            end
          end
          writer.li do
            if spanClass
              writer.span(class: spanClass) do
                line
              end
            else
              line
            end
          end
        end
        nil
      end
    end
    return title, writer.output
  end

  def renderTranslationError(message)
    title = 'Translation error'
    writer = getWriter
    writer.p(class: 'error') do
      "An error occurred: #{message}"
    end
    return title, writer.output
  end
end
