require 'tmpdir'
require 'fileutils'

module RTex
  
  class Tempdir
        
    class << self
      
      def open
        tempdir = new
        FileUtils.mkdir_p tempdir.path
        result = nil
        begin
          result = Dir.chdir(tempdir.path) do
            yield tempdir
          end
          tempdir.remove!
        ensure
          # If an error occurs, we *always* remove it
          tempdir.remove!
        end
        result
      end
      
    end
    
    def initialize(basename='rtex')
      @basename = basename
      @removed = false
    end
    
    def path
      @path ||= File.expand_path(File.join(Dir.tmpdir, "#{@basename}-#{uuid}"))
    end
    
    def remove!
      return false if @removed
      FileUtils.rm_rf path
      @removed = true
    end
    
    #######
    private
    #######
    
    # Try using uuidgen, but if that doesn't work drop down to
    # a poor-man's UUID; timestamp, thread & object hashes
    # Note: I don't want to add any dependencies (so no UUID library)
    def uuid
      if (result = `uuidgen`.strip rescue nil).empty?
        "#{Time.now.to_i}-#{Thread.current.hash}-#{hash}"
      else
        result
      end
    end
    
  end
  
end