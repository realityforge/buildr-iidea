# Based on lib/buildr/ide/idea7x.rb from Apache Buildr.
# Buildr's license is below

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with this
# work for additional information regarding copyright ownership.  The ASF
# licenses this file to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

module Buildr
  module IntellijIdea
    class IdeaModule < IdeaFile
      DEFAULT_TYPE = "JAVA_MODULE"
      DEFAULT_LOCAL_REPOSITORY_ENV_OVERRIDE = "M2_REPO"
      MODULE_DIR_URL = "file://$MODULE_DIR$"

      attr_writer :buildr_project
      attr_accessor :type
      attr_accessor :local_repository_env_override

      def initialize
        @type = DEFAULT_TYPE
        @local_repository_env_override = DEFAULT_LOCAL_REPOSITORY_ENV_OVERRIDE
      end

      def buildr_project=(buildr_project)
        @id = nil
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

      def main_dependencies
        buildr_project.compile.dependencies.map(&:to_s)
      end

      def test_dependencies
        buildr_project.test.compile.dependencies.map(&:to_s) - [ buildr_project.compile.target.to_s ]
      end

      def base_directory
        buildr_project.path_to
      end

      protected

      def base_document
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target).module(:version => "4", :relativePaths => "true", :type => self.type)
        REXML::Document.new(target.string)
      end

      def default_components
        [
            lambda { module_root_component }
        ]
      end

      def module_root_component
        m2repo = Buildr::Repositories.instance.local

        # Note: Use the test classpath since IDEA compiles both "main" and "test" classes using the same classpath
        deps = self.test_dependencies
        # Convert classpath elements into applicable Project objects
        deps.collect! { |path| Buildr.projects.detect { |prj| prj.packages.detect { |pkg| pkg.to_s == path } } || path }
        # project_libs: artifacts created by other projects
        project_libs, others = deps.partition { |path| path.is_a?(Project) }
        # Separate artifacts from Maven2 repository
        m2_libs, others = others.partition { |path| path.to_s.index(m2repo) == 0 }

        create_component("NewModuleRootManager", "inherit-compiler-output" => "false") do |xml|
          generate_compile_output(xml)
          generate_content(xml)
          generate_order_entries(project_libs, xml)

          ext_libs = m2_libs.map do |path|
            entry_path = path.to_s
            unless self.local_repository_env_override.nil?
              entry_path = entry_path.sub(m2repo, "$#{self.local_repository_env_override}$")
            end
            "jar://#{entry_path}!/"
          end
          self.resources.each do |resource|
            ext_libs << "#{MODULE_DIR_URL}/#{relative(resource.to_s)}"
          end

          generate_module_libs(xml, ext_libs)
          xml.orderEntryProperties
        end
      end

      def relative(path)
        Util.relative_path(File.expand_path(path.to_s), self.base_directory)
      end

      def generate_compile_output(xml)
        xml.output(:url => "#{MODULE_DIR_URL}/#{relative(self.main_output_dir.to_s)}")
        xml.tag!("output-test", :url => "#{MODULE_DIR_URL}/#{relative(self.test_output_dir.to_s)}")
        xml.tag!("exclude-output")
      end

      def generate_content(xml)
        xml.content(:url => MODULE_DIR_URL) do
          # Source folders
          {
              :main => self.main_source_directories,
              :test => self.test_source_directories
          }.each do |kind, directories|
            directories.map { |dir| relative(dir) }.compact.sort.uniq.each do |dir|
              xml.sourceFolder :url => "#{MODULE_DIR_URL}/#{dir}", :isTestSource => (kind == :test ? 'true' : 'false')
            end
          end

          # Exclude target directories
          self.net_excluded_directories.sort.each do |dir|
            xml.excludeFolder :url => "#{MODULE_DIR_URL}/#{dir}"
          end
        end
      end

      def generate_order_entries(project_libs, xml)
        xml.orderEntry :type => "sourceFolder", :forTests => "false"
        xml.orderEntry :type => "inheritedJdk"

        # Classpath elements from other projects
        project_libs.uniq.select { |p| p.iml? }.collect { |p| p.iml.name }.sort.each do |other_project|
          xml.orderEntry :type => 'module', "module-name" => other_project, :exported => ""
        end
      end

      def generate_module_libs(xml, ext_libs)
        ext_libs.each do |path|
          xml.orderEntry :type => "module-library", :exported => "" do
            xml.library do
              xml.CLASSES do
                xml.root :url => path
              end
              xml.JAVADOC # TODO
              xml.SOURCES # TODO
            end
          end
        end
      end

      # Don't exclude things that are subdirectories of other excluded things
      def net_excluded_directories
        net = []
        all = self.excluded_directories.map { |dir| relative(dir.to_s) }.sort_by { |d| d.size }
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