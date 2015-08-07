require 'tempfile'

module RTeX
  module Framework #:nodoc:   
    module Rails #:nodoc:
      
      def self.setup
        RTeX::Document.options[:tempdir] = File.expand_path(File.join(RAILS_ROOT, 'tmp'))
        if ActionView::Base.respond_to?(:register_template_handler)
          ActionView::Base.register_template_handler(:rtex, TemplateHandler)
        else
          ActionView::Template.register_template_handler(:rtex, TemplateHandler)
        end
        ActionController::Base.send(:include, ControllerMethods)
        ActionView::Base.send(:include, HelperMethods)
      end
      
      class TemplateHandler < ::ActionView::TemplateHandlers::ERB
        # Due to significant changes in ActionView over the lifespan of Rails,
        # tagging compiled templates to set a thread local variable flag seems
        # to be the least brittle approach.
        def compile(template)
          # Insert assignment, but not before the #coding: line, if present
          super.sub(/^(?!#)/m, "Thread.current[:_rendering_rtex] = true;\n")
        end
      end
      
      module ControllerMethods
        def self.included(base)
          base.alias_method_chain :render, :rtex
        end
        
        def render_with_rtex(options=nil, *args, &block)
          result = render_without_rtex(options, *args, &block)[0]
          if result.is_a?(String) && Thread.current[:_rendering_rtex]
            Thread.current[:_rendering_rtex] = false
            options ||= {}
            ::RTeX::Document.new(result, options.merge(:processed => true)).to_pdf do |filename|
              serve_file = Tempfile.new('rtex-pdf')
              FileUtils.mv filename, serve_file.path
              send_file serve_file.path,
                :disposition => (options[:disposition] rescue nil) || 'inline',
                :url_based_filename => true,
                :filename => (options[:filename] rescue nil),
                :type => "application/pdf"
              serve_file.close
            end
          else
            result
          end
          
        end
      end
      
      module HelperMethods
        # Similar to h()
        def latex_escape(*args)
          # Since Rails' I18n implementation aliases l() to localize(), LaTeX
          # escaping should only be done if RTeX is doing the rendering.
          # Otherwise, control should be be passed to localize().
          if Thread.current[:_rendering_rtex]
            RTeX::Document.escape(*args)
          else
            localize(*args)
          end
        end
        alias :l :latex_escape
      end
      
    end
  end
end
