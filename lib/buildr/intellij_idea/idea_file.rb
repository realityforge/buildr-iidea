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
    # Abstract base class for IdeaModule and IdeaProject
    class IdeaFile
      DEFAULT_SUFFIX = "-iidea"

      attr_reader :buildr_project

      attr_writer :suffix

      def suffix
        @suffix ||= DEFAULT_SUFFIX
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
  end
end