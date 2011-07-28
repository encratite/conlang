require 'www-library/BaseSite'

require 'application/TsiunSiteGenerator'

class TsiunSite < WWWLib::BaseSite
  def initialize
    super('tsiun', TsiunSiteGenerator)
  end
end
