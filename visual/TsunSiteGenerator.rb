require 'www-library/SiteGenerator'
require 'www-library/HTMLWriter'
require 'www-library/string'

class TsunSiteGenerator < WWWLib::SiteGenerator
  def render(request, content)
    writer = WWWLib::HTMLWriter.new
    writer.div(class: 'container') do
      writer.write(content)
    end
    return writer.output
  end
end
