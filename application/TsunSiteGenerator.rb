require 'visual/TsiunSiteGenerator'

require 'www-library/SiteGenerator'

class TsiunSiteGenerator < WWWLib::SiteGenerator
  Name = 'Tsiun'

  def initialize(site, manager)
    super(manager)
    @site = site
  end

  def get(content, request, title)
    content = render(request, content)
    fullTitle = "#{title} - #{Name}"
    super(fullTitle, content)
  end
end
