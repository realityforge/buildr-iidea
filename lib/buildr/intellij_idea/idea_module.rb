module Buildr
  module IntellijIdea
    class IdeaModule < IdeaFile
      DEFAULT_TYPE = "JAVA_MODULE"
      DEFAULT_LOCAL_REPOSITORY_ENV_OVERRIDE = "MAVEN_REPOSITORY"

      attr_accessor :type
      attr_accessor :local_repository_env_override
      attr_accessor :group
      attr_reader :facets

      def initialize
        @type = DEFAULT_TYPE
        @local_repository_env_override = DEFAULT_LOCAL_REPOSITORY_ENV_OVERRIDE
      end

      def buildr_project=(buildr_project)
        @id = nil
        @facets = []
        @skip_content = false
        @buildr_project = buildr_project
      end

      def extension
        "iml"
      end

      def main_source_directories
        @main_source_directories ||= [
            buildr_project.compile.sources,
            buildr_project.resources.sources
        ].flatten.compact
      end

      def test_source_directories
        @test_source_directories ||= [
            buildr_project.test.compile.sources,
            buildr_project.test.resources.sources
        ].flatten.compact
      end

      def excluded_directories
        @excluded_directories ||= [
            buildr_project.resources.target,
            buildr_project.test.resources.target,
            buildr_project.path_to(:target, :main),
            buildr_project.path_to(:target, :test),
            buildr_project.path_to(:reports)
        ].flatten.compact
      end

      def main_output_dir
        buildr_project.compile.target || buildr_project.path_to(:target, :main, 'idea')
      end

      def test_output_dir
        buildr_project.test.compile.target || buildr_project.path_to(:target, :test, 'idea')
      end

      def resources
        [buildr_project.test.resources.target, buildr_project.resources.target].compact
      end

      def test_dependencies
        main_dependencies_paths = buildr_project.compile.dependencies.map(&:to_s)
        target_dir = buildr_project.compile.target.to_s
        buildr_project.test.compile.dependencies.select{|d| d.to_s != target_dir}.collect do |d|
          dependency_path = d.to_s
          export = main_dependencies_paths.include?(dependency_path)
          source_path = nil
          if d.respond_to?(:to_spec_hash)
            source_spec = d.to_spec_hash.merge(:classifier => 'sources')
            source_path = Buildr.artifact(source_spec).to_s
            source_path = nil unless File.exist?(source_path)
          end
          [dependency_path, export, source_path]
        end

      end

      def base_directory
        buildr_project.path_to
      end

      def add_facet(name, type)
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target, :indent => 2).facet(:name => name, :type => type) do |xml|
          yield xml if block_given?
        end
        self.facets << REXML::Document.new(target.string).root
      end

      def skip_content?
        !!@skip_content
      end

      def skip_content!
        @skip_content = true
      end

      protected

      def base_document
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target).module(:version => "4", :relativePaths => "true", :type => self.type)
        REXML::Document.new(target.string)
      end

      def initial_components
        []
      end

      def default_components
        [
            lambda { module_root_component },
            lambda { facet_component }
        ]
      end

      def facet_component
        return nil if self.facets.empty?
        fm = self.create_component("FacetManager")
        self.facets.each do |facet|
          fm.add_element facet
        end
        fm
      end

      def module_root_component
        create_component("NewModuleRootManager", "inherit-compiler-output" => "false") do |xml|
          generate_compile_output(xml)
          generate_content(xml) unless skip_content?
          generate_initial_order_entries(xml)
          project_dependencies = []

          # Note: Use the test classpath since IDEA compiles both "main" and "test" classes using the same classpath
          self.test_dependencies.each do |dependency_path, export, source_path|
            project_for_dependency = Buildr.projects.detect do |project|
              [project.packages, project.compile.target, project.test.compile.target].flatten.
                detect { |proj_art| proj_art.to_s == dependency_path }
            end
            if project_for_dependency
              if project_for_dependency.iml? && !project_dependencies.include?(project_for_dependency)
                generate_project_dependency( xml, project_for_dependency.iml.name, export )
              end
              project_dependencies << project_for_dependency
              next
            else
              generate_module_lib(xml, url_for_path(dependency_path), export, (source_path ? url_for_path(source_path) : nil))
            end
          end

          self.resources.each do |resource|
            generate_module_lib(xml, file_path(resource.to_s), true, nil)
          end

          xml.orderEntryProperties
        end
      end

      def jar_path(path)
        "jar://#{resolve_path(path)}!/"
      end

      def file_path(path)
        "file://#{resolve_path(path)}"
      end

      def url_for_path(path)
        if path =~ /jar$/i
          jar_path(path)
        else
          file_path(path)
        end
      end

      def resolve_path(path)
        m2repo = Buildr::Repositories.instance.local
        if path.to_s.index(m2repo) == 0 && !self.local_repository_env_override.nil?
          return path.sub(m2repo, "$#{self.local_repository_env_override}$")
        else
          return "$MODULE_DIR$/#{relative(path)}"
        end
      end

      def relative(path)
        ::Buildr::Util.relative_path(File.expand_path(path.to_s), self.base_directory)
      end

      def generate_compile_output(xml)
        xml.output(:url => file_path(self.main_output_dir.to_s))
        xml.tag!("output-test", :url => file_path(self.test_output_dir.to_s))
        xml.tag!("exclude-output")
      end

      def generate_content(xml)
        xml.content(:url => "file://$MODULE_DIR$") do
          # Source folders
          {
              :main => self.main_source_directories,
              :test => self.test_source_directories
          }.each do |kind, directories|
            directories.map { |dir| dir.to_s }.compact.sort.uniq.each do |dir|
              xml.sourceFolder :url => file_path(dir), :isTestSource => (kind == :test ? 'true' : 'false')
            end
          end

          # Exclude target directories
          self.net_excluded_directories.
            collect { |dir| file_path(dir) }.
            select{ |dir| relative_dir_inside_dir?(dir) }.
            sort.each do |dir|
            xml.excludeFolder :url => dir
          end
        end
      end

      def relative_dir_inside_dir?(dir)
        !dir.include?("../")
      end

      def generate_initial_order_entries(xml)
        xml.orderEntry :type => "sourceFolder", :forTests => "false"
        xml.orderEntry :type => "inheritedJdk"
      end

      def generate_project_dependency(xml, other_project, export = true)
        attribs = {:type => 'module', "module-name" => other_project}
        attribs[:exported] = '' if export
        xml.orderEntry attribs
      end

      def generate_module_lib(xml, path, export, source_path)
        attribs = {:type => 'module-library'}
        attribs[:exported] = '' if export
        xml.orderEntry attribs do
          xml.library do
            xml.CLASSES do
              xml.root :url => path
            end
            xml.JAVADOC
            xml.SOURCES do
              if source_path
                xml.root :url => source_path
              end
            end
          end
        end
      end

      # Don't exclude things that are subdirectories of other excluded things
      def net_excluded_directories
        net = []
        all = self.excluded_directories.map { |dir| buildr_project._(dir.to_s) }.sort_by { |d| d.size }
        all.each_with_index do |dir, i|
          unless all[0 ... i].find { |other| dir =~ /^#{other}/ }
            net << dir
          end
        end
        net
      end
    end
  end
end