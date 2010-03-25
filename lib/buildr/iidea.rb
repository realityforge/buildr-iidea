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

module Buildr
  module IntellijIdea

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
  end
end

class Buildr::Project
  include Buildr::IntellijIdea
end
