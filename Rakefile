require 'rubygems'
require 'echoe'

require File.dirname(__FILE__) << "/lib/rtex/version"

Echoe.new 'rtex' do |p|
  p.version = RTeX::Version::STRING
  p.author = ['Bruce Williams', 'Wiebe Cazemier']
  p.email  = 'bruce@codefluency.com'
  p.project = 'rtex'
  p.summary = "LaTeX preprocessor for PDF generation; Rails plugin"
  p.url = "http://rtex.rubyforge.org"
  p.include_rakefile = true
  p.development_dependencies = %w(Shoulda echoe)
  p.rcov_options = '--exclude gems --exclude version.rb --sort coverage --text-summary --html -o coverage'
  p.ignore_pattern = /^(pkg|doc|site)|\.svn|CVS|\.bzr|\.DS|\.git/
  p.rubygems_version = nil
end

task :coverage do
  system "open coverage/index.html" if PLATFORM['darwin']
end
