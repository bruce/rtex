basepath = File.dirname(__FILE__) << '/rtex'

require basepath << '/document'

module RTex
  
  VERSION = '2.0.0'
  
  class << self
    
    def framework(name)
      require File.dirname(__FILE__) << "/rtex/framework/#{name}"
      framework = ::RTex::Framework.const_get(name.to_s.capitalize)
      framework.setup
    end
    
    def basic_layout #:nodoc:
      "\\documentclass[12pt]{article}\n\\begin{document}\n<%= yield %>\n\\end{document}"
    end
    
    def filter(name, &block)
      filters[name.to_s] = block
    end
    
    def filters #:nodoc:
      @filters ||= {}
    end
    
  end
  
  filter :textile do |source|
    require File.dirname(__FILE__) << '/../vendor/instiki/redcloth_for_tex'
    RedClothForTex.new(source).to_tex
  end
  
end


