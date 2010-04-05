module Buildr
  module IntellijIdea
    class IdeaProject < IdeaFile
      attr_accessor :vcs
      attr_accessor :extra_modules

      def initialize(buildr_project)
        @buildr_project = buildr_project
        @vcs = detect_vcs
        @extra_modules = []
      end

      protected

      def extension
        "ipr"
      end

      def detect_vcs
        if File.directory?(buildr_project._('.svn'))
          "svn"
        elsif File.directory?(buildr_project._('.git'))
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
        ]
      end

      def modules_component
        create_component("ProjectModuleManager") do |xml|
          xml.modules do
            buildr_project.projects.select { |subp| subp.iml? }.each do |subproject|
              module_path = subproject.base_dir.gsub(/^#{buildr_project.base_dir}\//, '')
              path = "#{module_path}/#{subproject.iml.name}.iml"
              attribs = { :fileurl => "file://$PROJECT_DIR$/#{path}", :filepath => "$PROJECT_DIR$/#{path}" }
              if subproject.iml.group == true
                attribs[:group] = subproject.parent.name.gsub(':', '/')
              elsif !subproject.iml.group.nil?
                attribs[:group] = subproject.group.to_s
              end
              xml.module attribs
            end
            self.extra_modules.each do |iml_file|
              xml.module :fileurl => "file://$PROJECT_DIR$/#{iml_file}",
                         :filepath => "$PROJECT_DIR$/#{iml_file}"
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
