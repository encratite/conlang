require 'www-library/BaseHandler'

class BaseHandler < WWWLib::BaseHandler
  def initialize(site)
    super(site)
    @database = site.database
  end
end
