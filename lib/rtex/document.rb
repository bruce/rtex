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
    
    # Handle preprocessing, if any
    def generate!(path) #:nodoc:
      if !preprocessor || preprocessor[path]
        unless generation_of path
          raise GenerationError, "Could not generate PDF using pdflatex (is it in PATH?)"      
        end
      end
    end
    
    def generation_of(path)
      `pdflatex --interaction=nonstopmode '#{path}'`
    end
    
    def generate_pdf_from(input, &file_handler)
      source_file = 'document.tex'
      log_file = 'document.log'
      result_file = 'document.pdf'
      full_path = nil
      Tempdir.open do |tempdir|
        # 1. Write everything into the temporary file...      
        File.open(source_file, 'wb') { |f| f.puts input }
        if @options[:tex]
          result_file = source_file
        else
          # 2. Generate the PDF
          generate!(source_file)
          # 3. Check for the pdf, and read it if needed
          unless File.exists?(result_file)
            if File.exists?(log_file)
              log = File.read(log_file)
              raise GenerationError, "Could not find result PDF #{result_file} after generation\n---LOG---\n#{log}\n---SOURCE---\n#{input}"
            else
              raise GenerationError, "Could not find result PDF #{result_file} after generation.\nNo log file found."
            end
          end
        end
        full_path = File.expand_path(File.join(tempdir.path, result_file))
        if file_handler
          yield full_path
        else
          File.open(full_path, 'rb') { |f| f.read }
        end
      end
    end
    
  end

end
