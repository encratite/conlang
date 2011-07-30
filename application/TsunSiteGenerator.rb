require 'visual/TsunSiteGenerator'

require 'www-library/SiteGenerator'

class TsunSiteGenerator < WWWLib::SiteGenerator
  Name = 'Tsun'

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
