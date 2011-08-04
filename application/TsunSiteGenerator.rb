require 'visual/ConlangSiteGenerator'

require 'www-library/SiteGenerator'

class ConlangSiteGenerator < WWWLib::SiteGenerator
  Name = 'Conlang'

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
