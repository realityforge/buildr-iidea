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

require 'buildr'
require 'stringio'

module Buildr::IntellijIdea
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
      iidea.enhance [ file(ideafile.filename) ]
      file(ideafile.filename => Buildr.application.buildfile) do |task|
        File.open(task.name, 'w') do |f|
          info "Writing #{task.name}"
          ideafile.write f
        end
      end
    end

    project.task("iidea:clean") do
      files.each { |f|
        info "Removing #{f.filename}" if File.exist?(f.filename)
        rm_rf f.filename
      }
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
      @iml ||= IdeaModule.new(self)
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

  # Abstract base class for IdeaModule and IdeaProject
  class IdeaFile
    attr_reader :buildr_project

    def initialize(buildr_project)
      @buildr_project = buildr_project
    end

    def self.component(name, attrs = {})
      markup = Builder::XmlMarkup.new(:target => StringIO.new, :indent => 2)
      markup.component(attrs.merge({ :name => name })) do |xml|
        yield xml if block_given?
      end
      REXML::Document.new(markup.target!.string).root
    end

    def components
      @components ||= self.default_components
    end

    def add_component(name, attrs = {}, &xml)
      self.components << IdeaFile.component(name, attrs, &xml)
      self
    end

    def document
      doc = base_document
      # replace overridden components, if any
      self.components.each do |comp_elt|
        # execute deferred components
        comp_elt = comp_elt.call if Proc === comp_elt
        if comp_elt
          doc.root.delete_element("//component[@name='#{comp_elt.attributes['name']}']")
          doc.root.add_element comp_elt
        end
      end
      doc
    end

    def write(f)
      document.write f
    end
  end

  class IdeaModule < IdeaFile
    DEFAULT_TYPE = "JAVA_MODULE"
    MODULE_DIR_URL = "file://$MODULE_DIR$"

    attr_writer :type

    def type
      @type ||= DEFAULT_TYPE
    end

    def filename
      buildr_project.path_to("#{name}.iml")
    end

    def name
      "#{buildr_project.id}-iidea"
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

    protected

    def base_document
      xml = Builder::XmlMarkup.new(:target => StringIO.new, :indent => 2)
      xml.module(:version=>"4", :relativePaths=>"true", :type=>self.type)
      REXML::Document.new(xml.target!.string)
    end

    def default_components
      [
        lambda { module_root_component }
      ]
    end

    def module_root_component
      m2repo = Buildr::Repositories.instance.local

      # Note: Use the test classpath since IDEA compiles both "main" and "test" classes using the same classpath
      deps = buildr_project.test.compile.dependencies.map(&:to_s) - [ buildr_project.compile.target.to_s ]
      # Convert classpath elements into applicable Project objects
      deps.collect! { |path| Buildr.projects.detect { |prj| prj.packages.detect { |pkg| pkg.to_s == path } } || path }
      # project_libs: artifacts created by other projects
      project_libs, others = deps.partition { |path| path.is_a?(Project) }
      # Separate artifacts from Maven2 repository
      m2_libs, others = others.partition { |path| path.to_s.index(m2repo) == 0 }

      IdeaModule.component("NewModuleRootManager", "inherit-compiler-output" => "false") do |xml|
        generate_compile_output(xml)
        generate_content(xml)
        generate_order_entries(project_libs, xml)

        ext_libs = m2_libs.map { |path| "jar://#{path.to_s.sub(m2repo, "$M2_REPO$")}!/" }
        [buildr_project.test.resources.target, buildr_project.resources.target].compact.each do |resource|
          ext_libs << "#{MODULE_DIR_URL}/#{relative(resource.to_s)}"
        end

        generate_module_libs(xml, ext_libs)
        xml.orderEntryProperties
      end
    end

    def relative(path)
      Util.relative_path(File.expand_path(path.to_s), buildr_project.path_to)
    end

    def generate_compile_output(xml)
      main_out = buildr_project.compile.target || buildr_project.path_to(:target, :main, 'idea')
      xml.output(:url => "#{MODULE_DIR_URL}/#{relative(main_out.to_s)}")

      test_out = buildr_project.test.compile.target || buildr_project.path_to(:target, :test, 'idea')
      xml.tag!("output-test", :url => "#{MODULE_DIR_URL}/#{relative(test_out.to_s)}")

      xml.tag!("exclude-output")
    end

    def generate_content(xml)
      xml.content(:url => MODULE_DIR_URL) do
        # Source folders
        {
          :main => main_source_directories,
          :test => test_source_directories
        }.each do |kind, directories|
          directories.map { |dir| relative(dir) }.compact.sort.uniq.each do |dir|
            xml.sourceFolder :url => "#{MODULE_DIR_URL}/#{dir}", :isTestSource => (kind == :test ? 'true' : 'false')
          end
        end

        # Exclude target directories
        net_excluded_directories.sort.each do |dir|
          xml.excludeFolder :url => "#{MODULE_DIR_URL}/#{dir}"
        end
      end
    end

    def generate_order_entries(project_libs, xml)
      xml.orderEntry :type => "sourceFolder", :forTests => "false"
      xml.orderEntry :type => "inheritedJdk"

      # Classpath elements from other projects
      project_libs.uniq.select { |p| p.iml? }.collect { |p| p.iml.name }.sort.each do |other_project|
        xml.orderEntry :type => 'module', "module-name" => other_project
      end
    end

    def generate_module_libs(xml, ext_libs)
      ext_libs.each do |path|
        xml.orderEntry :type => "module-library" do
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
      all = excluded_directories.map { |dir| relative(dir.to_s) }.sort_by { |d| d.size }
      all.each_with_index do |dir, i|
        unless all[0 ... i].find { |other| dir =~ /^#{other}/ }
          net << dir
        end
      end
      net
    end
  end

  class IdeaProject < IdeaFile
    attr_accessor :template, :vcs

    def filename
      buildr_project.path_to("#{buildr_project.name}-iidea.ipr")
    end

    def template
      @template ||= File.join(File.dirname(__FILE__), 'iidea.ipr.template')
    end

    def vcs
      @vcs ||= detect_vcs
    end

    protected

    def base_document
      REXML::Document.new(File.read(template))
    end

    def default_components
      [
        lambda { modules_component },
        vcs_component
      ].compact
    end

    def modules_component
      IdeaProject.component("ProjectModuleManager") do |xml|
        xml.modules do
          buildr_project.projects.select { |subp| subp.iml? }.each do |subp|
            module_path = subp.base_dir.gsub(/^#{buildr_project.base_dir}\//, '')
            path = "#{module_path}/#{subp.iml.name}.iml"
            xml.module :fileurl  => "file://$PROJECT_DIR$/#{path}",
                       :filepath => "$PROJECT_DIR$/#{path}"
          end
          if buildr_project.iml?
            xml.module :fileurl  => "file://$PROJECT_DIR$/#{buildr_project.iml.name}.iml",
                       :filepath => "$PROJECT_DIR$/#{buildr_project.iml.name}.iml"
          end
        end
      end
    end

    def vcs_component
      if vcs
        IdeaProject.component("VcsDirectoryMappings") do |xml|
          xml.mapping :directory => "", :vcs => vcs
        end
      end
    end

    def detect_vcs
      if File.directory?(buildr_project._('.svn'))
        "svn"
      elsif File.directory?(buildr_project._('.git')) # TODO: this might be in a parent directory
        "Git"
      end
    end
  end
end

class Buildr::Project
  include Buildr::IntellijIdea
end
