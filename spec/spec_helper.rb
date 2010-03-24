begin
  require File.expand_path("../../.bundle/environment", __FILE__)
rescue LoadError
  raise "Gem environment is not prepared.  Run `bundle install` before running specs."
end

require 'spec'

# hook into buildr's spec_helpers load process
unless defined?(SpecHelpers)
  module SandboxHook
    def SandboxHook.included(spec_helpers)
      $LOAD_PATH.unshift(File.dirname(__FILE__))
      $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
      require 'buildr/iidea'
    end
  end

  require File.expand_path('../../vendor/buildr/spec/spec_helpers', __FILE__)
end
