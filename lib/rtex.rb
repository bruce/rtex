$:.unshift(File.dirname(__FILE__) << '/rtex')

require 'document'
require 'version'

module RTex
    
  def self.framework(name)
    require File.dirname(__FILE__) << "/rtex/framework/#{name}"
    framework = ::RTex::Framework.const_get(name.to_s.capitalize)
    framework.setup
  end
  
  def self.basic_layout #:nodoc:
    "\\documentclass[12pt]{article}\n\\begin{document}\n<%= yield %>\n\\end{document}"
  end
  
  def self.filter(name, &block)
    filters[name.to_s] = block
  end
  
  def self.filters #:nodoc:
    @filters ||= {}
  end
  
  filter :textile do |source|
    require File.dirname(__FILE__) << '/../vendor/instiki/redcloth_for_tex'
    RedClothForTex.new(source).to_tex
  end
  
end


