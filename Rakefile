require File.dirname(__FILE__) << "/lib/rtex/version"

load 'tasks/setup.rb'

PROJ.name = 'rtex'
PROJ.authors = ['Bruce Williams', 'Wiebe Cazemier']
PROJ.email = ['bruce@codefluency.com']
PROJ.url = 'http://rtex.rubyforge.org'
PROJ.rubyforge_name = 'rtex'

PROJ.libs = %w[]
PROJ.ruby_opts = []
PROJ.test_opts = []

PROJ.rdoc_main = 'README.rdoc'
PROJ.rdoc_include.push 'README.rdoc', 'README_RAILS.rdoc'

PROJ.description = "LaTeX preprocessor for PDF generation; Rails plugin"
PROJ.summary = PROJ.description

PROJ.version = RTeX::Version::STRING

task 'gem:package' => 'manifest:assert'