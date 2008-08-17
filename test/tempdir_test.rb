require File.dirname(__FILE__) << '/test_helper'

class TempdirTest < Test::Unit::TestCase

  context "Creating a temporary directory" do
  
    setup do
      change_tmpdir_for_testing
    end
  
    should "change directory" do
      old_location = Dir.pwd
      block_location = nil
      RTeX::Tempdir.open do
        assert_not_equal old_location, Dir.pwd
        block_location = Dir.pwd
      end
      assert_equal old_location, Dir.pwd
      assert !File.exists?(block_location)
    end
  
    should "use a 'rtex' name prefix" do
      RTeX::Tempdir.open do
        assert_equal 'rtex-', File.basename(Dir.pwd)[0,5]
      end
    end
  
    should "remove the directory after use if no exception occurs by default" do
      path = nil
      RTeX::Tempdir.open do
        path = Dir.pwd
        assert File.exists?(path)
      end
      assert !File.exists?(path)
    end
  
    should "return the result of the last statement if automatically removing the directory" do
      result = RTeX::Tempdir.open do
        :last
      end
      assert_equal :last, :last
    end
  
    should "return the result of the last statment if not automatically removing the directory" do
      tempdir = nil # to capture value
      result = RTeX::Tempdir.open do |tempdir|
        :last
      end
      tempdir.remove!
      assert_equal :last, :last
    end
  
    should "not remove the directory after use if an exception occurs" do
      path = nil
      assert_raises RuntimeError do
        RTeX::Tempdir.open do
          path = Dir.pwd
          assert File.directory?(path)
          raise "Test exception!"
        end
      end
      assert File.directory?(path)
    end
  
  end
  
end