require 'www-library/BaseSite'

require 'application/TsiunSiteGenerator'

require 'sequel'

class TsiunSite < WWWLib::BaseSite
  attr_reader :database

  def initialize(configuration)
    super('tsiun', TsiunSiteGenerator)
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
