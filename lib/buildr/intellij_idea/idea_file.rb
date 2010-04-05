module Buildr
  module IntellijIdea
    # Abstract base class for IdeaModule and IdeaProject
    class IdeaFile
      DEFAULT_SUFFIX = ""

      attr_reader :buildr_project
      attr_writer :suffix
      attr_writer :id
      attr_accessor :template

      def suffix
        @suffix ||= DEFAULT_SUFFIX
      end

      def filename
        buildr_project.path_to("#{name}.#{extension}")
      end

      def id
        @id ||= buildr_project.name.split(':').last
      end

      def add_component(name, attrs = {}, &xml)
        self.components << create_component(name, attrs, &xml)
      end

      def write(f)
        document.write f
      end

      protected

      def name
        "#{self.id}#{suffix}"
      end

      def create_component(name, attrs = {})
        target = StringIO.new
        Builder::XmlMarkup.new(:target => target, :indent => 2).component(attrs.merge({ :name => name })) do |xml|
          yield xml if block_given?
        end
        REXML::Document.new(target.string).root
      end

      def components
        @components ||= self.default_components.compact
      end

      def load_document(filename)
        REXML::Document.new(File.read(filename))
      end

      def document
        if File.exist?(self.filename)
          doc = load_document(self.filename)
        else
          doc = base_document
          inject_components( doc, self.initial_components )
        end
        if self.template
          template_doc = load_document(self.template)
          REXML::XPath.each(template_doc, "//component") do |element|
            inject_component(doc, element)
          end
        end
        inject_components( doc, self.components )
        doc
      end

      def inject_components(doc, components)
        components.each do |component|
          # execute deferred components
          component = component.call if Proc === component
          inject_component(doc, component) if component
        end
      end

      # replace overridden component (if any) with specified component
      def inject_component(doc, component)
        doc.root.delete_element("//component[@name='#{component.attributes['name']}']")
        doc.root.add_element component
      end
    end
  end
end