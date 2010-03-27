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
    class IdeaProject < IdeaFile
      attr_accessor :template, :vcs

      def initialize(buildr_project)
        @buildr_project = buildr_project
      end
      
      def filename
        buildr_project.path_to("#{buildr_project.name}#{Buildr::IntellijIdea::Config.suffix}.ipr")
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
end
