module RTex
  
  module Escaping
    
    def escape(text)
      replacements.inject(text) do |corpus, (pattern, replacement)|
        corpus.gsub(pattern, replacement)
      end
    end
    
    def replacements
      @replacements ||= [
        [/([{}])/,    '\\\1'],
        [/\\/,        '\textbackslash{}'],
        [/\^/,        '\textasciicircum{}'],
        [/~/,         '\textasciitilde{}'],
        [/\|/,        '\textbar{}'],
        [/\</,        '\textless{}'],
        [/\>/,        '\textgreater{}'],
        [/([_$&%#])/, '\\\1']
      ]
    end
    
  end
  
end