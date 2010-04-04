module Buildr
  module IntellijIdea
    class IdeaProject < IdeaFile
      attr_accessor :vcs

      def initialize(buildr_project)
        @buildr_project = buildr_project
        @vcs = detect_vcs
        self.template = File.join(File.dirname(__FILE__), 'iidea.ipr.template')
      end

      protected

      def extension
        "ipr"
      end

      def detect_vcs
        if File.directory?(buildr_project._('.svn'))
          "svn"
        elsif File.directory?(buildr_project._('.git')) # TODO: this might be in a parent directory
          "Git"
        end
      end

      def base_document
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target).project(:version => "4", :relativePaths => "false")
        REXML::Document.new(target.string)
      end

      def default_components
        [
            lambda { modules_component },
            vcs_component
        ].compact
      end

      def modules_component
        create_component("ProjectModuleManager") do |xml|
          xml.modules do
            buildr_project.projects.select { |subp| subp.iml? }.each do |subp|
              module_path = subp.base_dir.gsub(/^#{buildr_project.base_dir}\//, '')
              path = "#{module_path}/#{subp.iml.name}.iml"
              xml.module :fileurl => "file://$PROJECT_DIR$/#{path}",
                         :filepath => "$PROJECT_DIR$/#{path}"
            end
            if buildr_project.iml?
              xml.module :fileurl => "file://$PROJECT_DIR$/#{buildr_project.iml.name}.iml",
                         :filepath => "$PROJECT_DIR$/#{buildr_project.iml.name}.iml"
            end
          end
        end
      end

      def vcs_component
        if vcs
          create_component("VcsDirectoryMappings") do |xml|
            xml.mapping :directory => "", :vcs => vcs
          end
        end
      end
    end
  end
end
