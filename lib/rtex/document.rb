require 'erb'
require 'ostruct'
require File.dirname(__FILE__) << '/tempdir'

module RTex
  
  class Document
    
    class FilterError < ::StandardError; end
    class GenerationError < ::StandardError; end
    
    attr_reader :preprocessor
    def initialize(content, options={})
      if options[:processed]
        @source = content
      else
        @erb = ERB.new(content)
      end
      @options = options
    end
    
    def source(binding=nil)
      @source ||= wrap_in_layout do
        filter @erb.result(binding)
      end
    end
    
    def filter(text)
      return text unless @options[:filter]
      if (process = RTex.filters[@options[:filter]])
        process[text]
      else
        raise FilterError, "No `#{@options[:filter]}' filter"
      end
    end
    
    def wrap_in_layout
      if @options[:layout]
        ERB.new(@options[:layout]).result(binding)
      else
        yield
      end
    end
    
    def to_pdf(binding=nil, &file_handler)
      generate_pdf_from(source(binding), &file_handler)
    end
    
    def preprocess(&block)
      @preprocessor = block
    end
        
    #######
    private
    #######
    
    def generate_pdf_from(input, &file_handler)
      Tempdir.open do |tempdir|
        prepare input
        if generating?
          generate!
          verify!
        end
        if file_handler
          yield full_path_in(tempdir.path)
        else
          result_as_string
        end
      end
    end
    
    # Handle preprocessing, if any
    def generate! #:nodoc:
      if !preprocessor || preprocessor[source_file]
        unless generation_of source_file
          raise GenerationError, "Could not generate PDF using pdflatex (is it in PATH?)"      
        end
      end
    end
    
    def generation_of(path)
      `pdflatex --interaction=nonstopmode '#{path}'`
    end
    
    def source_file
      @source_file ||= file(:tex)
    end
    
    def log_file
      @log_file ||= file(:log)
    end
    
    def result_file
      @result_file ||= file(@options[:tex] ? :tex : :pdf)
    end
    
    def file(extension)
      "document.#{extension}"
    end
    
    def generating?
      !@options[:tex]
    end
    
    def verify!
      unless File.exists?(result_file)
        raise GenerationError, "Could not find result PDF #{result_file} after generation.\nCheck #{File.expand_path(log_file)}"
      end
    end
    
    def prepare(input)
      File.open(source_file, 'wb') { |f| f.puts input }
    end
    
    def result_as_string
      File.open(result_file, 'rb') { |f| f.read }
    end
    
    def full_path_in(directory)
      File.expand_path(File.join(directory, result_file))
    end
    
  end

end
