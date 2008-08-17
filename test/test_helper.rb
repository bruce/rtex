require 'test/unit'

require 'rubygems'
begin
  require 'shoulda'
  require 'flexmock/test_unit'
rescue LoadError
  abort "the `Shoulda' and `flexmock' gems are required for testing"
end

require File.dirname(__FILE__) << '/../lib/rtex'

class Test::Unit::TestCase
  
  def change_tmpdir_for_testing
    flexmock(Dir).should_receive(:tmpdir).and_return(File.dirname(__FILE__) << '/tmp')
  end

  def document(name, options={})
    name = name.kind_of?(Symbol) ? "#{name}.tex.erb" : name
    template = File.read(File.dirname(__FILE__) << "/fixtures/#{name}")
    RTeX::Document.new(template, options)
  end

end
  