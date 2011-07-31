require 'www-library/BaseSite'

require 'application/database'
require 'application/TsunSiteGenerator'

class TsunSite < WWWLib::BaseSite
  attr_reader :database, :privilegedAddresses

  def initialize(configuration)
    super('tsun', TsunSiteGenerator)
    @privilegedAddresses = configuration::PrivilegedAddresses
    @database = getDatabase(configuration::Database)
  end
end
