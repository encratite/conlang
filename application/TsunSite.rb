require 'www-library/BaseSite'

require 'application/database'
require 'application/ConlangSiteGenerator'

class ConlangSite < WWWLib::BaseSite
  attr_reader :database, :privilegedAddresses

  def initialize(configuration)
    super('conlang', ConlangSiteGenerator)
    @privilegedAddresses = configuration::PrivilegedAddresses
    @database = getDatabase(configuration::Database)
  end
end
