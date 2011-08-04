$:.concat ['.', '..']

require 'configuration/Configuration'

require 'application/ConlangSite'
require 'application/LanguageHandler'

conlangSite = ConlangSite.new(Configuration)
LanguageHandler.new(conlangSite)

handler = lambda do |environment|
  conlangSite.requestManager.handleRequest(environment)
end

run(handler)
