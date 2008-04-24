try_require 'uv'
require 'hpricot'
require File.dirname(__FILE__) << "/../../lib/rtex/version"

def stable_version
  if defined?(RTeX::Version::DESCRIPTION)
    RTeX::Version::STRING + " (#{RTeX::Version::DESCRIPTION})"
  else
    RTeX::Version::STRING
  end
end

UV_THEME = 'dawn'

::Webby.site.uv = { :theme => UV_THEME }

Webby::Filters.register :erb do |input, cursor|
  b = cursor.renderer.get_binding
  replaced = {}
  input.gsub!(/<quote-erb>(.*?)<\/quote-erb>/) do |match|
    key = "(quote-erb_#{match.object_id})"
    highlighted = Hpricot(Uv.parse($1, "xhtml", 'html_rails', false, UV_THEME))
    source = highlighted.at('pre > span.EmbeddedSource').inner_html
    replaced[key] = source
    key
  end
  replaced.inject(ERB.new(input, nil, '-').result(b)) do |result, (key, value)|
    result.sub(key, value)
  end
end
