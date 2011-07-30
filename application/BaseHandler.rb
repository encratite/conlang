require 'www-library/BaseHandler'

class BaseHandler < WWWLib::BaseHandler
  def initialize(site)
    super(site)
    @database = site.database
  end

  def isPrivileged(request)
    return @site.privilegedAddresses.include?(request.address)
  end

  def privilegeCheck(request)
    if !isPrivileged(request)
      permissionError
    end
  end
end
