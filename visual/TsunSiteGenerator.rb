require 'www-library/SiteGenerator'
require 'www-library/HTMLWriter'
require 'www-library/string'

class TsunSiteGenerator < WWWLib::SiteGenerator
  def render(request, content)
    writer = WWWLib::HTMLWriter.new
    writer.div(class: 'container') do
      request.handler.getMenu.each do |menuLevel|
        writer.ul(class: 'menu') do
          menuLevel.each do |item|
            writer.li do
              writer.a(href: WWWLib.slashify(item.path)) { item.description }
            end
          end
        end
      end
      writer.write(content)
    end
    return writer.output
  end
end
