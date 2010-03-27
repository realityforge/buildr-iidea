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
      require 'buildr_iidea'
    end
  end

  require File.expand_path('../../vendor/buildr/spec/spec_helpers', __FILE__)

  module SpecHelpers
    def root_project_filename(project_name)
      "#{project_name}#{Buildr::IntellijIdea::IdeaFile::DEFAULT_SUFFIX}.ipr"
    end

    def root_module_filename(project_name)
      "#{project_name}#{Buildr::IntellijIdea::IdeaFile::DEFAULT_SUFFIX}.iml"
    end

    def subproject_module_filename(parent_project_name, project_name)
      "#{project_name}/#{parent_project_name}-#{project_name}#{Buildr::IntellijIdea::IdeaFile::DEFAULT_SUFFIX}.iml"
    end
  end

end
