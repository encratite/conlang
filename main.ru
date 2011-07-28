$:.concat ['.', '..']

require 'application/TsiunSite'
require 'application/LanguageHandler'

tsiunSite = TsiunSite.new
LanguageHandler.new(tsiunSite)

handler = lambda do |environment|
  tsiunSite.requestManager.handleRequest(environment)
end

run(handler)
