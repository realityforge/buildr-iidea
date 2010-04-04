require 'stringio'

module Buildr
  module IntellijIdea
    module ProjectExtension

      include Extension

      first_time do
        desc "Generate Intellij IDEA artifacts for all projects"
        Project.local_task "iidea" => "artifacts"

        desc "Delete the generated Intellij IDEA artifacts"
        Project.local_task "iidea:clean"
      end

      before_define do |project|
        project.recursive_task("iidea")
        project.recursive_task("iidea:clean")
      end

      after_define do |project|
        iidea = project.task("iidea")

        files = [
            (project.iml if project.iml?),
            (project.ipr if project.ipr?)
        ].compact

        files.each do |ideafile|
          module_dir =  File.dirname(ideafile.filename)         
          # Need to clear the actions else the extension included as part of buildr will run
          file(ideafile.filename).clear_actions
          directory(module_dir)
          iidea.enhance [ file(ideafile.filename) ]
          file(ideafile.filename => [Buildr.application.buildfile, module_dir]) do |task|
            info "Writing #{task.name}"
            temp_filename = nil
            Tempfile.open("buildr-iidea") do |f|
              temp_filename = f.path
              ideafile.write f
            end
            mv temp_filename, ideafile.filename
          end
        end

        project.task("iidea:clean") do
          files.each do |f|
            info "Removing #{f.filename}" if File.exist?(f.filename)
            rm_rf f.filename
          end
        end
      end

      def ipr
        if ipr?
          @ipr ||= IdeaProject.new(self)
        else
          raise "Only the root project has an IPR"
        end
      end

      def ipr?
        self.parent.nil?
      end

      def iml
        if iml?
          unless @iml
            @iml = self.parent ? self.parent.iml.clone : IdeaModule.new
            @iml.buildr_project = self
          end
          return @iml
        else
          raise "IML generation is disabled for #{self.name}"
        end
      end

      def no_iml
        @has_iml = false
      end

      def iml?
        @has_iml = @has_iml.nil? ? true : @has_iml
      end
    end
  end
end

class Buildr::Project
  include Buildr::IntellijIdea::ProjectExtension
end
