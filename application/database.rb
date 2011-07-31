require 'sequel'

def getDatabase(databaseConfiguration)
  configuration = {
    adapter: databaseConfiguration::Adapter,
    host: databaseConfiguration::Host,
    user: databaseConfiguration::User,
    password: databaseConfiguration::Password,
    database: databaseConfiguration::Database,
  }
  return Sequel.connect(configuration)
end
