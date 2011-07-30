require 'www-library/BaseSite'

require 'application/TsunSiteGenerator'

require 'sequel'

class TsunSite < WWWLib::BaseSite
  attr_reader :database, :privilegedAddresses

  def initialize(configuration)
    super('tsun', TsunSiteGenerator)
    @privilegedAddresses = configuration::PrivilegedAddresses
    databaseConfiguration = configuration::Database
    @database =
      Sequel.connect(
                     adapter: databaseConfiguration::Adapter,
                     host: databaseConfiguration::Host,
                     user: databaseConfiguration::User,
                     password: databaseConfiguration::Password,
                     database: databaseConfiguration::Database
                     )
  end
end
