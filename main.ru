$:.concat ['.', '..']

require 'configuration/Configuration'

require 'application/TsunSite'
require 'application/LanguageHandler'

tsunSite = TsunSite.new(Configuration)
LanguageHandler.new(tsunSite)

handler = lambda do |environment|
  tsunSite.requestManager.handleRequest(environment)
end

run(handler)
