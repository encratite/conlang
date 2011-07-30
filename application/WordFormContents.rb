require 'nil/symbol'

class WordFormContents
  include SymbolicAssignment

  SymbolMap = {
    id: :id,
    function: :function_name,
    argumentCount: :argument_count,
    word: :word,
    description: :description,
    aliasDefinition: :alias_definition,
    group: :group_name,
    rank: :group_rank,
  }

  attr_reader *SymbolMap.keys

  def initialize(row)
    SymbolMap.each do |symbol, rowSymbol|
      setMember(symbol, row[rowSymbol])
    end
  end
end
