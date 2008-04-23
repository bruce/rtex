require File.dirname(__FILE__) << "/../../lib/rtex/version"

def stable_version
  if defined?(RTeX::Version::DESCRIPTION)
    RTeX::Version::STRING + " (#{RTeX::Version::DESCRIPTION})"
  else
    RTeX::Version::STRING
  end
end